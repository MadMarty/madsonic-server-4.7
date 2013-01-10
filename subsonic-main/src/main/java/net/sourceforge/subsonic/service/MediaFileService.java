/*
 This file is part of Subsonic.

 Subsonic is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 Subsonic is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with Subsonic.  If not, see <http://www.gnu.org/licenses/>.

 Copyright 2009 (C) Sindre Mehus
 */
package net.sourceforge.subsonic.service;

import net.sf.ehcache.Ehcache;
import net.sf.ehcache.Element;
import net.sourceforge.subsonic.Logger;
import net.sourceforge.subsonic.dao.AlbumDao;
import net.sourceforge.subsonic.dao.MediaFileDao;
import net.sourceforge.subsonic.domain.Album;
import net.sourceforge.subsonic.domain.MediaFile;
import net.sourceforge.subsonic.domain.MediaFileComparator;
import net.sourceforge.subsonic.domain.MediaFile.MediaType;
import net.sourceforge.subsonic.domain.MusicFolder;
import net.sourceforge.subsonic.service.metadata.JaudiotaggerParser;
import net.sourceforge.subsonic.service.metadata.MetaData;
import net.sourceforge.subsonic.service.metadata.MetaDataParser;
import net.sourceforge.subsonic.service.metadata.MetaDataParserFactory;
import net.sourceforge.subsonic.util.FileUtil;
import net.sourceforge.subsonic.util.StringUtil;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang.StringUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import static net.sourceforge.subsonic.domain.MediaFile.MediaType.*;

/**
 * Provides services for instantiating and caching media files and cover art.
 *
 * @author Sindre Mehus
 */
public class MediaFileService {

    private static final Logger LOG = Logger.getLogger(MediaFileService.class);

    private Ehcache mediaFileMemoryCache;

    private SecurityService securityService;
    private SettingsService settingsService;
    private MediaFileDao mediaFileDao;
    private AlbumDao albumDao;
    private MetaDataParserFactory metaDataParserFactory;


    
    /**
     * Returns a media file instance for the given file.  If possible, a cached value is returned.
     *
     * @param file A file on the local file system.
     * @return A media file instance, or null if not found.
     * @throws SecurityException If access is denied to the given file.
     */
    public MediaFile getMediaFile(File file) {
        return getMediaFile(file, settingsService.isFastCacheEnabled());
    }

    /**
     * Returns a media file instance for the given file.  If possible, a cached value is returned.
     *
     * @param file A file on the local file system.
     * @return A media file instance, or null if not found.
     * @throws SecurityException If access is denied to the given file.
     */
    public MediaFile getMediaFile(File file, boolean useFastCache) {

        // Look in fast memory cache first.
        Element element = mediaFileMemoryCache.get(file);
        MediaFile result = element == null ? null : (MediaFile) element.getObjectValue();
        if (result != null) {
            return result;
        }

        if (!securityService.isReadAllowed(file)) {
       // 	return null;
            throw new SecurityException("Access denied to file " + file);
        }

        // Secondly, look in database.
        result = mediaFileDao.getMediaFile(file.getPath());
        if (result != null) {
            result = checkLastModified(result, useFastCache);
            mediaFileMemoryCache.put(new Element(file, result));
            return result;
        }

        if (!FileUtil.exists(file)) {
            return null;
        }
        // Not found in database, must read from disk.
        result = createMediaFile(file);

        // Put in cache and database.
        mediaFileMemoryCache.put(new Element(file, result));
        mediaFileDao.createOrUpdateMediaFile(result);

        return result;
    }

    private MediaFile checkLastModified(MediaFile mediaFile, boolean useFastCache) {
        if (useFastCache || mediaFile.getChanged().getTime() >= FileUtil.lastModified(mediaFile.getFile())) {
            return mediaFile;
        }
        mediaFile = createMediaFile(mediaFile.getFile());
        mediaFileDao.createOrUpdateMediaFile(mediaFile);
        return  mediaFile;
    }

    /**
     * Returns a media file instance for the given path name. If possible, a cached value is returned.
     *
     * @param pathName A path name for a file on the local file system.
     * @return A media file instance.
     * @throws SecurityException If access is denied to the given file.
     */
    public MediaFile getMediaFile(String pathName) {
        return getMediaFile(new File(pathName));
    }

    // TODO: Optimize with memory caching.
    public MediaFile getMediaFile(int id, int user_group_id) {
        MediaFile mediaFile = mediaFileDao.getMediaFile(id);
        if (mediaFile == null) {
            return null;
        }

        if (!securityService.isAccessAllowed(mediaFile.getFile(), user_group_id) ) {
        	return null;
        }else
        {
	        if (!securityService.isReadAllowed(mediaFile.getFile())) {
	            throw new SecurityException("Access denied to file " + mediaFile);
	        }
        }

        return checkLastModified(mediaFile, settingsService.isFastCacheEnabled());
    }

    public MediaFile getMediaFile(int id) {
        MediaFile mediaFile = mediaFileDao.getMediaFile(id);
        if (mediaFile == null) {
            return null;
        }

        if (!securityService.isReadAllowed(mediaFile.getFile())) {
            throw new SecurityException("Access denied to file " + mediaFile);
        }

        return checkLastModified(mediaFile, settingsService.isFastCacheEnabled());
    }    
    
    public MediaFile getParentOf(MediaFile mediaFile) {
        if (mediaFile.getParentPath() == null) {
            return null;
        }
        return getMediaFile(mediaFile.getParentPath());
    }

    public List<MediaFile> getChildrenOf(String parentPath, boolean includeFiles, boolean includeDirectories, boolean sort) {
        return getChildrenOf(new File(parentPath), includeFiles, includeDirectories, sort);
    }

	public List<MediaFile> getChildrenOf(List<MediaFile> children, boolean includeFiles,
			boolean includeDirectories, boolean sort) {
		
        List<MediaFile> result = new ArrayList<MediaFile>();
        for (MediaFile child : children) {

            if (child.isDirectory() && includeDirectories) {
                result.add(child);
            }
            if (child.isFile() && includeFiles) {
                result.add(child);
            }
        }
		return result;
		
	}    
    
    public List<MediaFile> getChildrenOf(File parent, boolean includeFiles, boolean includeDirectories, boolean sort) {
        return getChildrenOf(getMediaFile(parent), includeFiles, includeDirectories, sort);
    }

    /**
     * Returns all media files that are children of a given media file.
     *
     * @param includeFiles       Whether files should be included in the result.
     * @param includeDirectories Whether directories should be included in the result.
     * @param sort               Whether to sort files in the same directory.
     * @return All children media files.
     */
    public List<MediaFile> getChildrenOf(MediaFile parent, boolean includeFiles, boolean includeDirectories, boolean sort) {
        return getChildrenOf(parent, includeFiles, includeDirectories, sort, settingsService.isFastCacheEnabled());
    }

    /**
     * Returns all media files that are children of a given media file.
     *
     * @param includeFiles       Whether files should be included in the result.
     * @param includeDirectories Whether directories should be included in the result.
     * @param sort               Whether to sort files in the same directory.
     * @return All children media files.
     */
    public List<MediaFile> getChildrenOf(MediaFile parent, boolean includeFiles, boolean includeDirectories, boolean sort, boolean useFastCache) {

        if (!parent.isDirectory()) {
            return Collections.emptyList();
        }

        // Make sure children are stored and up-to-date in the database.
        if (!useFastCache) {
            updateChildren(parent);
        }

        List<MediaFile> result = new ArrayList<MediaFile>();
        for (MediaFile child : mediaFileDao.getChildrenOf(parent.getPath())) {
            child = checkLastModified(child, useFastCache);
            if (child.isDirectory() && includeDirectories) {
                result.add(child);
            }
            if (child.isFile() && includeFiles) {
                result.add(child);
            }
        }

        if (sort) {
           Comparator<MediaFile> comparator = new MediaFileComparator();
            // Note: Intentionally not using Collections.sort() since it can be problematic on Java 7.
            // http://www.oracle.com/technetwork/java/javase/compatibility-417013.html#jdk7
            Set<MediaFile> set = new TreeSet<MediaFile>(comparator);
            set.addAll(result);
            result = new ArrayList<MediaFile>(set);

//            Collections.sort(result, new MediaFileSorter());
        }

        return result;
    }

    /**
     * Returns whether the given file is the root of a media folder.
     *
     * @see MusicFolder
     */
    public boolean isRoot(MediaFile mediaFile) {
        for (MusicFolder musicFolder : settingsService.getAllMusicFolders(false, true)) {
            if (mediaFile.getPath().equals(musicFolder.getPath().getPath())) {
                return true;
            }
        }
        return false;
    }

    /**
     * Returns all genres in the music collection.
     *
     * @return Sorted list of genres.
     */
    public List<String> getGenres(int user_group_id) {
        return mediaFileDao.getGenres(user_group_id);
    }

    public List<String> getGenres() {
        return mediaFileDao.getGenres();
    }    
    
    /**
     * Returns the most frequently played albums.
     *
     * @param offset Number of albums to skip.
     * @param count  Maximum number of albums to return.
     * @return The most frequently played albums.
     */
    public List<MediaFile> getMostFrequentlyPlayedAlbums(int offset, int count, int user_group_id) {
        return mediaFileDao.getMostFrequentlyPlayedAlbums(offset, count, user_group_id);
    }

    /**
     * Returns the most recently played albums.
     *
     * @param offset Number of albums to skip.
     * @param count  Maximum number of albums to return.
     * @return The most recently played albums.
     */
    public List<MediaFile> getMostRecentlyPlayedAlbums(int offset, int count, int user_group_id) {
        return mediaFileDao.getMostRecentlyPlayedAlbums(offset, count, user_group_id);
    }

    /**
     * Returns the most recently added albums.
     *
     * @param offset Number of albums to skip.
     * @param count  Maximum number of albums to return.
     * @return The most recently added albums.
     */
    public List<MediaFile> getNewestAlbums(int offset, int count, int user_group_id) {
        return mediaFileDao.getNewestAlbums(offset, count, user_group_id);
    }

    /**
     * Returns the most recently starred albums.
     *
     * @param offset   Number of albums to skip.
     * @param count    Maximum number of albums to return.
     * @param username Returns albums starred by this user.
     * @return The most recently starred albums for this user.
     */
    public List<MediaFile> getStarredAlbums(int offset, int count, String username) {
        return mediaFileDao.getStarredAlbums(offset, count, username);
    }

    /**
     * Returns albums in alphabetial order.
     *
     *
     * @param offset Number of albums to skip.
     * @param count  Maximum number of albums to return.
     * @param byArtist Whether to sort by artist name
     * @return Albums in alphabetical order.
     */
    public List<MediaFile> getAlphabetialAlbums(int offset, int count, boolean byArtist, int user_group_id) {
        return mediaFileDao.getAlphabetialAlbums(offset, count, byArtist, user_group_id);
    }

    public Date getMediaFileStarredDate(int id, String username) {
        return mediaFileDao.getMediaFileStarredDate(id, username);
    }

    public void populateStarredDate(List<MediaFile> mediaFiles, String username) {
        for (MediaFile mediaFile : mediaFiles) {
            populateStarredDate(mediaFile, username);
        }
    }

    public void populateStarredDate(MediaFile mediaFile, String username) {
        Date starredDate = mediaFileDao.getMediaFileStarredDate(mediaFile.getId(), username);
        mediaFile.setStarredDate(starredDate);
    }
    
//	public void updateMediaType(Integer id, String mediaType, boolean Override) throws Exception {
//
//		//TODO: UpdateMediaType
//
//		mediaFile.setMediaTypeOverride(Override);
//		mediaFile.setMediaType(ALBUM);
//		mediaFileDao.createOrUpdateMediaFile(mediaFile);
//	}	

	public void updateMediaType(Integer id, String mediaType, boolean override) {
		// TODO Auto-generated method stub
	}    
    
    private void updateChildren(MediaFile parent) {

        // Check timestamps.
        if (parent.getChildrenLastUpdated().getTime() >= parent.getChanged().getTime()) {
            return;
        }

        List<MediaFile> storedChildren = mediaFileDao.getChildrenOf(parent.getPath());
        Map<String, MediaFile> storedChildrenMap = new HashMap<String, MediaFile>();
        for (MediaFile child : storedChildren) {
            storedChildrenMap.put(child.getPath(), child);
        }

        List<File> children = filterMediaFiles(FileUtil.listFiles(parent.getFile()));
        for (File child : children) {
            if (storedChildrenMap.remove(child.getPath()) == null) {
                // Add children that are not already stored.
                mediaFileDao.createOrUpdateMediaFile(createMediaFile(child));
            }
        }

        // Delete children that no longer exist on disk.
        for (String path : storedChildrenMap.keySet()) {
            mediaFileDao.deleteMediaFile(path);
        }

        // Update timestamp in parent.
        parent.setChildrenLastUpdated(parent.getChanged());
        parent.setPresent(true);
        mediaFileDao.createOrUpdateMediaFile(parent);
    }

    private List<File> filterMediaFiles(File[] candidates) {
        List<File> result = new ArrayList<File>();
        for (File candidate : candidates) {
            String suffix = FilenameUtils.getExtension(candidate.getName()).toLowerCase();
            try {
				if (!isExcluded(candidate) && (FileUtil.isDirectory(candidate) || isAudioFile(suffix) || isVideoFile(suffix))) {
				    result.add(candidate);
				}
			} catch (IOException e) {
				// TODO Auto-generated catch block
			}
        }
        return result;
    }

    private boolean isAudioFile(String suffix) {
        for (String s : settingsService.getMusicFileTypesAsArray()) {
            if (suffix.equals(s.toLowerCase())) {
                return true;
            }
        }
        return false;
    }

    private boolean isVideoFile(String suffix) {
        for (String s : settingsService.getVideoFileTypesAsArray()) {
            if (suffix.equals(s.toLowerCase())) {
                return true;
            }
        }
        return false;
    }
    

 
    private Set<String> excludes;

    /**
     * Returns whether the given file is excluded, i.e., whether it is listed in 'madsonic_exclude.txt' in
     * the current directory.
     *
     * @param file The child file in question.
     * @return Whether the child file is excluded.
     */	 
	private boolean isExcluded(File file) throws IOException {

        if (file.getName().startsWith(".") || file.getName().startsWith("@eaDir") || file.getName().toLowerCase().equals("thumbs.db") ) {
            return true;
        }

        File excludeFile = new File(file.getParentFile().getPath(), "madsonic_exclude.txt");
        if (excludeFile.exists()) {
            excludes = new HashSet<String>();
		
    		LOG.info("### excludeFile found: " + excludeFile + " ###" );
            String[] lines = StringUtil.readLines(new FileInputStream(excludeFile));
            for (String line : lines) {
                excludes.add(line.toLowerCase());
            }
			return excludes.contains(file.getName().toLowerCase());		
        }
        
    return false;    
    }

    private MediaFile createMediaFile(File file) {
        MediaFile existingFile = mediaFileDao.getMediaFile(file.getPath());
        MediaFile mediaFile = new MediaFile();
        Date lastModified = new Date(FileUtil.lastModified(file));
        mediaFile.setPath(file.getPath());
        mediaFile.setFolder(securityService.getRootFolderForFile(file));
        mediaFile.setParentPath(file.getParent());
        mediaFile.setChanged(lastModified);
        mediaFile.setLastScanned(new Date());
        mediaFile.setPlayCount(existingFile == null ? 0 : existingFile.getPlayCount());
        mediaFile.setLastPlayed(existingFile == null ? null : existingFile.getLastPlayed());
        mediaFile.setComment(existingFile == null ? null : existingFile.getComment());
        mediaFile.setChildrenLastUpdated(new Date(0));
        mediaFile.setCreated(lastModified);
        
//		mediaFile.setMediaType(ALBUM);
		mediaFile.setMediaType(DIRECTORY);
		
        // #### Scan Foldernamer for Year #####
        if (StringUtil.truncatedYear(file.getName()) != null && StringUtil.truncatedYear(file.getName()) > 10){
            mediaFile.setYear(StringUtil.truncatedYear(file.getName()));
        }		

        //TODO:SCAN ALBUMS
    	   try{
	   			if (isRoot(mediaFile)) { mediaFile.setMediaType(DIRECTORY); }
    	   }
    	   catch (Exception x) {
			LOG.error("Failed to get parent", x);
    	   }
    	   
        mediaFile.setPresent(true);
        
		//  ################# Look for cover art. ##################
		try {
			FilenameFilter PictureFilter = new FilenameFilter() {
				public boolean accept(File dir, String name) {
				String lowercaseName = name.toLowerCase();
				if (lowercaseName.endsWith("png"))  	 { return true; }
				else if (lowercaseName.endsWith("jpg"))  { return true; }
				else if (lowercaseName.endsWith("jpeg")) { return true; }
				else if (lowercaseName.endsWith("gif"))  { return true; }
				else if (lowercaseName.endsWith("bmp"))  { return true; }
				else { return false;}
				}};
			File[] Albumchildren = FileUtil.listFiles(file, PictureFilter, true);
			File coverArt = findCoverArt(Albumchildren);
			if (coverArt != null) {
				mediaFile.setCoverArtPath(coverArt.getPath());
			}
		} catch (IOException x) {
			LOG.error("Failed to find cover art for DIRECTORY .", x);
		}
		
		//  ################# MEDIA_TYPE MUSIC #####################
        if (file.isFile()) {

            MetaDataParser parser = metaDataParserFactory.getParser(file);
            if (parser != null) {
                MetaData metaData = parser.getMetaData(file);
                mediaFile.setArtist(metaData.getArtist());
                mediaFile.setAlbumArtist(metaData.getAlbumArtist());
                mediaFile.setAlbumName(metaData.getAlbumName());
                mediaFile.setTitle(metaData.getTitle());
                mediaFile.setDiscNumber(metaData.getDiscNumber());
                mediaFile.setTrackNumber(metaData.getTrackNumber());
                mediaFile.setGenre(metaData.getGenre());
                mediaFile.setYear(metaData.getYear());
                mediaFile.setDurationSeconds(metaData.getDurationSeconds());
                mediaFile.setBitRate(metaData.getBitRate());
                mediaFile.setVariableBitRate(metaData.getVariableBitRate());
                mediaFile.setHeight(metaData.getHeight());
                mediaFile.setWidth(metaData.getWidth());
            }
            String format = StringUtils.trimToNull(StringUtils.lowerCase(FilenameUtils.getExtension(mediaFile.getPath())));
            mediaFile.setFormat(format);
            mediaFile.setFileSize(FileUtil.length(file));
            mediaFile.setMediaType(getMediaType(mediaFile));

        } else {
            // ############## Is this an album? ########################
        	if (!isRoot(mediaFile)) {
                File[] children = FileUtil.listFiles(file);
                File firstChild = null;
                for (File child : filterMediaFiles(children)) {
                    if (FileUtil.isFile(child)) {
                        firstChild = child;
                        break;
                    }
                }

                if (firstChild != null) {
                    mediaFile.setMediaType(ALBUM);

                    // ######### Guess artist/album name and year. #######
                    MetaDataParser parser = metaDataParserFactory.getParser(firstChild);
                    if (parser != null) {
                        MetaData metaData = parser.getMetaData(firstChild);
                        
//                      mediaFile.setArtist(metaData.getArtist());
                        mediaFile.setArtist(StringUtils.isBlank(metaData.getAlbumArtist()) ? metaData.getArtist() : metaData.getAlbumArtist());
                        
                        // ########## SET Genre & Yeas for album #########
                        mediaFile.setGenre(metaData.getGenre());
                        if (metaData.getYear() != null)
                        {	mediaFile.setYear(metaData.getYear());                        	
							mediaFile.setYear(metaData.getYear());
                        }
						
						// ########## BETTER Albumset Detection #########	
						String AlbumSetName = StringUtil.truncateYear(parser.guessAlbum(firstChild, mediaFile.getArtist())); 
						String parentAlbumSetName = parser.guessArtist(firstChild);
						
			//			mediaFile.setArtist(parser.guessArtist(mediaFile.getFile()));
                        String searchAlbum = searchforAlbumSetName(AlbumSetName, AlbumSetName);
                        
                        if ( AlbumSetName == searchAlbum ) {
                            mediaFile.setAlbumName(StringUtil.truncateYear(metaData.getAlbumName()));
                            mediaFile.setAlbumSetName(StringUtil.truncateYear(AlbumSetName));
                        }
                        else
                        {	mediaFile.setAlbumName(StringUtil.truncateYear(metaData.getAlbumName()));
                            mediaFile.setAlbumSetName(StringUtil.truncateYear(searchforAlbumSetName(AlbumSetName, StringUtil.truncateYear(parentAlbumSetName) )));
							LOG.info("### MediaType ALBUMSET: " + searchforAlbumSetName(AlbumSetName, StringUtil.truncateYear(parentAlbumSetName)) + " ###" );

                        }
                    }

                    // ####### Look for cover art. ########
                    try {
                        File coverArt = findCoverArt(children);
                        if (coverArt != null) {
                            mediaFile.setCoverArtPath(coverArt.getPath());
                        }
                    } catch (IOException x) {
                        LOG.error("Failed to find cover art.", x);
                    }

                } else {


					// ##### Look for child type  #######
					File firstAudioChild = null;
					File firstFolderChild = null;
					
                    for (File child : filterMediaFiles(children)) {
					
                        if (FileUtil.isDirectory(child)) {
                            firstFolderChild = child;
                        }
                        if (FileUtil.isFile(child)) {
                            firstAudioChild = child;
                            break;
                        }
                    }

                    if (firstFolderChild != null) {
                        File[] firstAlbumChild = FileUtil.listFiles(firstFolderChild);
                        for (File child : filterMediaFiles(firstAlbumChild)) {
                            if (FileUtil.isFile(child)) {
	    	                    MetaDataParser ChildParser = metaDataParserFactory.getParser(child);
	    	                    if (ChildParser != null) {
	    	                        MetaData metaDataChild = ChildParser.getMetaData(child);
	    	                        mediaFile.setGenre(metaDataChild.getGenre());
	    	                        if (metaDataChild.getYear() != null)
	    	                        {	mediaFile.setYear(metaDataChild.getYear()); }
	    	                    }
                                break;
                            }
                        }
					}
                    if (firstAudioChild != null) {
	                    MetaDataParser ChildParser = metaDataParserFactory.getParser(firstAudioChild);
	                    if (ChildParser != null) {
	                        MetaData metaDataChild = ChildParser.getMetaData(firstAudioChild);
							mediaFile.setGenre(metaDataChild.getGenre());
	                        if (metaDataChild.getYear() != null)
	                        {	mediaFile.setYear(metaDataChild.getYear()); }
	                    }
                    }
                    
				// ######## ALBUMSET ###############
                  if (firstAudioChild == null) {
              		mediaFile.setMediaType(ALBUMSET);
  			        mediaFile.setArtist(StringUtil.truncateYear(new File(file.getParent()).getName()));
                    mediaFile.setAlbumName(StringUtil.truncateYear(file.getName()));
                    mediaFile.setAlbumSetName(StringUtil.truncateYear(file.getName()));
					LOG.info("### MediaType ALBUMSET: " + StringUtil.truncateYear(file.getName()) + " ###" );
                  }     
				  else
				  {
                    mediaFile.setArtist(StringUtil.truncateYear(file.getName()));
				  }
                  
                  if (mediaFile.getArtist() != null) {
                  if (mediaFile.getParentPath().contains(mediaFile.getArtist()))
                  {
                		mediaFile.setMediaType(ALBUMSET);           	  
                  		mediaFile.setArtist(StringUtil.truncateYear(new File(file.getParent()).getName()));
						LOG.info("### MediaType ALBUMSET: " + StringUtil.truncateYear(new File(file.getParent()).getName()) + " ###" );
                  }


				// ######## ARTIST ###############
	              if (mediaFile.getCoverArtPath() == null) {
	                		mediaFile.setMediaType(ARTIST);
	    			        mediaFile.setArtist(StringUtil.truncateYear(file.getName()));
							LOG.info("### MediaType ARTIST: " + StringUtil.truncateYear(file.getName()) + " ###" );
	              }  
                }

				// ######## ARTIST ###############
                  if (mediaFile.getCoverArtPath() != null) {
                  	String lowercaseName = (mediaFile.getCoverArtPath().toLowerCase());
                  	if (lowercaseName.contains("artist")) {
	                		mediaFile.setMediaType(ARTIST);
	    			        mediaFile.setArtist(StringUtil.truncateYear(file.getName()));
							LOG.info("### MediaType ARTIST: " + StringUtil.truncateYear(file.getName()) + " ###" );
                  	}
                  }                	

              	// ################## Look for Artist flag ###############
				setMediaTypeFlag (mediaFile, file, "MULTI.TAG",  MULTIARTIST);
				setMediaTypeFlag (mediaFile, file, "ARTIST.TAG", ARTIST); 
				setMediaTypeFlag (mediaFile, file, "ALBUM.TAG",  ALBUM); 
				setMediaTypeFlag (mediaFile, file, "SET.TAG",    ALBUMSET);
				setMediaTypeFlag (mediaFile, file, "DIR.TAG",    DIRECTORY);
                }
            }
        }
        return mediaFile;
    }

    /**
     * Set MediaType if File TAG Flag is found
     */
	private boolean setMediaTypeFlag(MediaFile mediaFile, File file, final String flagname, MediaType mediaType){
						
	FilenameFilter FlagFilter = new FilenameFilter() {
		public boolean accept(File dir, String name) {
			String lowercaseName = name.toLowerCase();
			if (lowercaseName.contains(flagname.toLowerCase())) {
				return true;  }
		 else { return false; }
		}};
	File[] FlagChildren = FileUtil.listFiles(file, FlagFilter, true);
    for (File candidate : FlagChildren) {
		if (candidate.isFile()) {
            mediaFile.setMediaType(mediaType);
			LOG.info("### MediaType " + mediaType + ": " + file.getName() + " ###" );
			return true;
		}}
		return false;
	}
    
    /**
     * Returns a converted Albumsetname for the given parent folder.
     */
    private String searchforAlbumSetName(String albumname, String parentalbumname ) {
	    int i = 1;
		boolean AlbumSetFound;
	    while(i<10) {
		    String[] strArray = {"CD"+i,"CD "+i,
								 "DISC"+i,"DISC "+i,
								 "DISK"+i,"DISK "+i,
								 "TEIL"+i,"TEIL "+i,
								 "PART"+i,"PART "+i};
		    AlbumSetFound = false;

			for (String searchTerm : strArray) {
		    	if (albumname.toLowerCase().contains(searchTerm.toLowerCase())) { 
		    		AlbumSetFound = true; } 
			}
			if (AlbumSetFound == true) {
				parentalbumname = parentalbumname + " - Disk"+i;
	            }
	    i++;
	    }
		return parentalbumname;   
    }
    
    private MediaFile.MediaType getMediaType(MediaFile mediaFile) {
        if (isVideoFile(mediaFile.getFormat())) {
            return VIDEO;
        }
        String path = mediaFile.getPath().toLowerCase();
        String genre = StringUtils.trimToEmpty(mediaFile.getGenre()).toLowerCase();
        if (path.contains("podcast") || genre.contains("podcast")) {
            return PODCAST;
        }
        if (path.contains("audiobook") || genre.contains("audiobook") || path.contains("audio book") || genre.contains("audio book")) {
            return AUDIOBOOK;
        }
        return MUSIC;
    }
    
    public void refreshMediaFile(MediaFile mediaFile) {
        mediaFile = createMediaFile(mediaFile.getFile());
        mediaFileDao.createOrUpdateMediaFile(mediaFile);
        mediaFileMemoryCache.remove(mediaFile.getFile());
    }

    /**
     * Returns a cover art image for the given media file.
     */
    public File getCoverArt(MediaFile mediaFile) {
        if (mediaFile.getCoverArtFile() != null) {
            return mediaFile.getCoverArtFile();
        }
        MediaFile parent = getParentOf(mediaFile);
        return parent == null ? null : parent.getCoverArtFile();
    }

    /**
     * Finds a cover art image for the given directory, by looking for it on the disk.
     */
    private File findCoverArt(File[] candidates) throws IOException {
        for (String mask : settingsService.getCoverArtFileTypesAsArray()) {
            for (File candidate : candidates) {
                if (candidate.isFile() && candidate.getName().toUpperCase().endsWith(mask.toUpperCase()) && !candidate.getName().startsWith(".")) {
                    return candidate;
                }
            }
        }

        // Look for embedded images in audiofiles. (Only check first audio file encountered).
        JaudiotaggerParser parser = new JaudiotaggerParser();
        for (File candidate : candidates) {
            if (parser.isApplicable(candidate)) {
                if (parser.isImageAvailable(getMediaFile(candidate))) {
                    return candidate;
                } else {
                    return null;
                }
            }
        }
        return null;
    }

    public void setSecurityService(SecurityService securityService) {
        this.securityService = securityService;
    }

    public void setSettingsService(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    public void setMediaFileMemoryCache(Ehcache mediaFileMemoryCache) {
        this.mediaFileMemoryCache = mediaFileMemoryCache;
    }

    public void setMediaFileDao(MediaFileDao mediaFileDao) {
        this.mediaFileDao = mediaFileDao;
    }

    /**
     * Returns all media files that are children, grand-children etc of a given media file.
     * Directories are not included in the result.
     *
     * @param sort Whether to sort files in the same directory.
     * @return All descendant music files.
     */
    public List<MediaFile> getDescendantsOf(MediaFile ancestor, boolean sort) {

        if (ancestor.isFile()) {
            return Arrays.asList(ancestor);
        }

        List<MediaFile> result = new ArrayList<MediaFile>();

        for (MediaFile child : getChildrenOf(ancestor, true, true, sort)) {
            if (child.isDirectory()) {
                result.addAll(getDescendantsOf(child, sort));
            } else {
                result.add(child);
            }
        }
        return result;
    }

    public void setMetaDataParserFactory(MetaDataParserFactory metaDataParserFactory) {
        this.metaDataParserFactory = metaDataParserFactory;
    }

    public void updateMediaFile(MediaFile mediaFile) {
        mediaFileDao.createOrUpdateMediaFile(mediaFile);
    }

    /**
     * Increments the play count and last played date for the given media file 
     */
    public void updateStatisticsUser(String username, MediaFile mediaFile) {
    	mediaFileDao.setPlayCountForUser(username, mediaFile);
    }
    
    /**
     * Increments the play count and last played date for the given media file and its
     * directory and album.
     */
    public void incrementPlayCount(MediaFile file) {
        Date now = new Date();
        file.setLastPlayed(now);
        file.setPlayCount(file.getPlayCount() + 1);
        updateMediaFile(file);

        MediaFile parent = getParentOf(file);
        if (!isRoot(parent)) {
            parent.setLastPlayed(now);
            parent.setPlayCount(parent.getPlayCount() + 1);
            updateMediaFile(parent);
        }

        Album album = albumDao.getAlbum(file.getAlbumArtist(), file.getAlbumName());
        if (album != null) {
            album.setLastPlayed(now);
            album.setPlayCount(album.getPlayCount() + 1);
            albumDao.createOrUpdateAlbum(album);
        }
    }

    public void setAlbumDao(AlbumDao albumDao) {
        this.albumDao = albumDao;
    }
}
