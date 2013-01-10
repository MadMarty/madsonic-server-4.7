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
package net.sourceforge.subsonic.controller;

import net.sourceforge.subsonic.domain.*;
import net.sourceforge.subsonic.service.*;
import net.sourceforge.subsonic.service.metadata.MetaData;
import net.sourceforge.subsonic.service.metadata.MetaDataParser;
import net.sourceforge.subsonic.service.metadata.MetaDataParserFactory;
import net.sourceforge.subsonic.service.metadata.JaudiotaggerParser;

import org.apache.commons.io.FilenameUtils;
import org.springframework.web.bind.ServletRequestUtils;
import org.springframework.web.servlet.*;
import org.springframework.web.servlet.mvc.*;

import javax.servlet.http.*;
import java.util.*;

/**
 * Controller for the page used to edit MP3 tags.
 *
 * @author Sindre Mehus
 */
public class EditTagsController extends ParameterizableViewController {

    private MetaDataParserFactory metaDataParserFactory;
    private MediaFileService mediaFileService;

    protected ModelAndView handleRequestInternal(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int id = ServletRequestUtils.getRequiredIntParameter(request, "id");
        MediaFile dir = mediaFileService.getMediaFile(id);
        List<MediaFile> files = mediaFileService.getChildrenOf(dir, true, false, true);

        Map<String, Object> map = new HashMap<String, Object>();
        if (!files.isEmpty()) {
            map.put("defaultArtist", files.get(0).getArtist());
            map.put("defaultAlbumArtist", files.get(0).getAlbumArtist());
            map.put("defaultAlbum", files.get(0).getAlbumName());
            map.put("defaultYear", files.get(0).getYear());
            map.put("defaultGenre", files.get(0).getGenre());
        }
        map.put("allGenres", JaudiotaggerParser.getID3V1Genres());

        List<Song> songs = new ArrayList<Song>();
        for (int i = 0; i < files.size(); i++) {
            songs.add(createSong(files.get(i), i));
        }
        map.put("id", id);
        map.put("songs", songs);

        ModelAndView result = super.handleRequestInternal(request, response);
        result.addObject("model", map);
        return result;
    }
    

    private Song createSong(MediaFile file, int index) {
        MetaDataParser parser = metaDataParserFactory.getParser(file.getFile());
        MetaData metaData = parser.getRawMetaData(file.getFile());

        Song song = new Song();
        song.setId(file.getId());
        song.setFileName(FilenameUtils.getBaseName(file.getPath()));
        song.setTrack(metaData.getTrackNumber());
        song.setSuggestedTrack(index + 1);
        song.setTitle(metaData.getTitle());
        song.setSuggestedTitle(parser.guessTitle(file.getFile()));
        song.setArtist(metaData.getArtist());
        song.setAlbumArtist(metaData.getAlbumArtist());
//		song.setAlbumArtist("DEBUG");
        song.setAlbum(metaData.getAlbumName());
        song.setYear(metaData.getYear());
        song.setGenre(metaData.getGenre());
        return song;
    }

    public void setMetaDataParserFactory(MetaDataParserFactory metaDataParserFactory) {
        this.metaDataParserFactory = metaDataParserFactory;
    }

    public void setMediaFileService(MediaFileService mediaFileService) {
        this.mediaFileService = mediaFileService;
    }

    /**
     * Contains information about a single song.
     */
    public static class Song {
        private int id;
        private String fileName;
        private Integer suggestedTrack;
        private Integer track;
        private String suggestedTitle;
        private String title;
        private String artist;
        private String albumartist;
        private String album;
        private Integer year;
        private String genre;

        public int getId() {
            return id;
        }

        public void setId(int id) {
            this.id = id;
        }

        public String getFileName() {
            return fileName;
        }

        public void setFileName(String fileName) {
            this.fileName = fileName;
        }

        public Integer getSuggestedTrack() {
            return suggestedTrack;
        }

        public void setSuggestedTrack(Integer suggestedTrack) {
            this.suggestedTrack = suggestedTrack;
        }

        public Integer getTrack() {
            return track;
        }

        public void setTrack(Integer track) {
            this.track = track;
        }

        public String getSuggestedTitle() {
            return suggestedTitle;
        }

        public void setSuggestedTitle(String suggestedTitle) {
            this.suggestedTitle = suggestedTitle;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getArtist() {
            return artist;
        }

        public String getAlbumArtist() {
            return albumartist;
        }

        public void setArtist(String artist) {
            this.artist = artist;
        }

        public void setAlbumArtist(String albumArtist) {
            this.albumartist = albumArtist;
        }

        public String getAlbum() {
            return album;
        }

        public void setAlbum(String album) {
            this.album = album;
        }

        public Integer getYear() {
            return year;
        }

        public void setYear(Integer year) {
            this.year = year;
        }

        public String getGenre() {
            return genre;
        }

        public void setGenre(String genre) {
            this.genre = genre;
        }
    }
}
