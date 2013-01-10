<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%--@elvariable id="model" type="java.util.Map"--%>

<html><head>
<%@ include file="head.jsp" %>
<%@ include file="jquery.jsp" %>

<link href="<c:url value="/style/shadow.css"/>" rel="stylesheet">

<c:if test="${not model.updateNowPlaying}">
	<meta http-equiv="refresh" content="180;URL=nowPlaying.view?">
</c:if>

<c:if test="${model.customScrollbar}">
<style type="text/css">
	.content_main{position:absolute; left:0px; top:0px; margin-left:10px; margin-top:10px; width:99%; height:95%; padding:0 0;overflow:auto;}
</style>
<script type="text/javascript" src="<c:url value="/script/jquery.mousewheel.min.js"/>"></script>
<script type="text/javascript" src="<c:url value="/script/jquery.mCustomScrollbar.js"/>"></script>
</c:if>	

<script type="text/javascript" src="<c:url value="/dwr/engine.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dwr/interface/starService.js"/>"></script>
<script type="text/javascript" src="<c:url value="/dwr/interface/playlistService.js"/>"></script>
<script type="text/javascript" src="<c:url value="/script/fancyzoom/FancyZoom.js"/>"></script>
<script type="text/javascript" src="<c:url value="/script/fancyzoom/FancyZoomHTML.js"/>"></script>

</head><body class="mainframe bgcolor1" onload="init();">

<!-- content block -->

<div id="content_2" class="content_main">
<!-- CONTENT -->

<sub:url value="createShare.view" var="shareUrl">
    <sub:param name="dir" value="${model.dir.path}"/>
</sub:url>
<sub:url value="download.view" var="downloadUrl">
    <sub:param name="dir" value="${model.dir.path}"/>
</sub:url>
<sub:url value="appendPlaylist.view" var="appendPlaylistUrl">
    <sub:param name="dir" value="${model.dir.path}"/>
</sub:url>

<script type="text/javascript" language="javascript">
    function init() {
        setupZoom('<c:url value="/"/>');

        $("#dialog-select-playlist").dialog({resizable: true, height: 350, position: [300,'center'], modal: true, autoOpen: false,
            buttons: {
                "<fmt:message key="common.cancel"/>": function() {
                    $(this).dialog("close");
                }
            }});
			
		//TODO: RefreshMedia	
		RefreshMediaType();
    }

    <!-- actionSelected() is invoked when the users selects from the "More actions..." combo box. -->
    function actionSelected(id) {

        if (id == "top") {
            return;
        } else if (id == "selectAll") {
            selectAll(true);
        } else if (id == "selectNone") {
            selectAll(false);
        } else if (id == "share") {
            parent.frames.main.location.href = "${shareUrl}&" + getSelectedIndexes();
        } else if (id == "download") {
            location.href = "${downloadUrl}&" + getSelectedIndexes();
        } else if (id == "appendPlaylist") {
            onAppendPlaylist();
        }
        $("#moreActions").prop("selectedIndex", 0);
    }

    function getSelectedIndexes() {
        var result = "";
        for (var i = 0; i < ${fn:length(model.children)}; i++) {
            var checkbox = $("#songIndex" + i);
            if (checkbox != null  && checkbox.is(":checked")) {
                result += "i=" + i + "&";
            }
        }
        return result;
    }

    function selectAll(b) {
        for (var i = 0; i < ${fn:length(model.children)}; i++) {
            var checkbox = $("#songIndex" + i);
            if (checkbox != null) {
                if (b) {
                    checkbox.attr("checked", "checked");
                } else {
                    checkbox.removeAttr("checked");
                }
            }
        }
    }

    function toggleStar(mediaFileId, imageId) {
        if ($(imageId).attr("src").indexOf("<spring:theme code="ratingOnImage"/>") != -1) {
            $(imageId).attr("src", "<spring:theme code="ratingOffImage"/>");
            starService.unstar(mediaFileId);
        }
        else if ($(imageId).attr("src").indexOf("<spring:theme code="ratingOffImage"/>") != -1) {
            $(imageId).attr("src", "<spring:theme code="ratingOnImage"/>");
            starService.star(mediaFileId);
        }
    }

    function onAppendPlaylist() {
        playlistService.getWritablePlaylists(playlistCallback);
    }
    function playlistCallback(playlists) {
        $("#dialog-select-playlist-list").empty();
        for (var i = 0; i < playlists.length; i++) {
            var playlist = playlists[i];
            $("<p class='dense'><b><a href='#' onclick='appendPlaylist(" + playlist.id + ")'>" + playlist.name + "</a></b></p>").appendTo("#dialog-select-playlist-list");
        }
        $("#dialog-select-playlist").dialog("open");
    }
    function appendPlaylist(playlistId) {
        $("#dialog-select-playlist").dialog("close");

        var mediaFileIds = new Array();
        for (var i = 0; i < ${fn:length(model.children)}; i++) {
            var checkbox = $("#songIndex" + i);
            if (checkbox && checkbox.is(":checked")) {
                mediaFileIds.push($("#songId" + i).html());
            }
        }
        playlistService.appendToPlaylist(playlistId, mediaFileIds, function (){top.left.updatePlaylists();});
    }

function RefreshMediaType() {

//	console.log("--RefreshGUI--");
	var mediatype = document.getElementsByName("mediatype");
	for (var i=0; i < mediatype.length; i++) {
		if (mediatype[i].checked == true) {
			console.log("The " + (i + 1) + ". radio button is checked");
		}
	}	
	if ("${model.dir.mediaType}" == "MULTIARTIST") { mediatype[0].checked=true; }
	if ("${model.dir.mediaType}" == "ARTIST") 	   { mediatype[1].checked=true; }
	if ("${model.dir.mediaType}" == "ALBUMSET")    { mediatype[2].checked=true; }
	if ("${model.dir.mediaType}" == "ALBUM")       { mediatype[3].checked=true; }
	if ("${model.dir.mediaType}" == "DIRECTORY")   { mediatype[4].checked=true; }
	if ("${model.dir.mediaTypeOverride}"=="false") { mediatype[5].checked=true; }
	}
</script>

<c:if test="${model.updateNowPlaying}">

    <script type="text/javascript" language="javascript">
        // Variable used by javascript in playlist.jsp
        var updateNowPlaying = true;
    </script>
</c:if>

<h1>
    <a href="#" style="text-decoration:none;" onclick="toggleStar(${model.dir.id}, '#starImage'); return false;">
        <c:choose>
            <c:when test="${not empty model.dir.starredDate}">
                <img id="starImage" src="<spring:theme code="ratingOnImage"/>" alt="">
			</c:when>
            <c:otherwise>
                <img id="starImage" src="<spring:theme code="ratingOffImage"/>" alt="">
			</c:otherwise>
        </c:choose></a>

    <c:forEach items="${model.ancestors}" var="ancestor">
        <sub:url value="main.view" var="ancestorUrl">
            <sub:param name="id" value="${ancestor.id}"/>
		</sub:url>
		
	<c:choose>
		<c:when test="${fn:startsWith(ancestor.name,'[')}">
			<a href="${ancestorUrl}">${fn:split(ancestor.name,']')[1]}</a> &raquo;
		</c:when>
		<c:otherwise>
			<a href="${ancestorUrl}">${ancestor.name}</a> &raquo;
		</c:otherwise>
	</c:choose>		
    </c:forEach>

	<c:choose>
		<c:when test="${not empty model.dir.albumSetName}">
			${model.dir.albumSetName}
		</c:when>
		<c:otherwise>
			${model.dir.name}
		</c:otherwise>
	</c:choose>		

    <c:if test="${model.dir.album and model.averageRating gt 0}">
        &nbsp;&nbsp;
        <c:import url="rating.jsp">
            <c:param name="path" value="${model.dir.path}"/>
            <c:param name="readonly" value="true"/>
            <c:param name="rating" value="${model.averageRating}"/>
        </c:import>
    </c:if>
</h1>

<c:if test="${not model.partyMode}">
<h2>
    <c:if test="${model.navigateUpAllowed}">
        <sub:url value="main.view" var="upUrl">
            <sub:param name="id" value="${model.parent.id}"/>
		</sub:url>
        <a href="${upUrl}"><fmt:message key="main.up"/></a>
        <c:set var="needSep" value="true"/>
    </c:if>

    <c:if test="${model.user.streamRole}">
        <c:if test="${needSep}">|</c:if>
        <a href="#" onclick="top.playQueue.onPlay(${model.dir.id});"><fmt:message key="main.playall"/></a> |
        <a href="#" onclick="top.playQueue.onPlayRandom(${model.dir.id}, 10);"><fmt:message key="main.playrandom"/></a> |
        <a href="#" onclick="top.playQueue.onAdd(${model.dir.id});"><fmt:message key="main.addall"/></a>
        <c:set var="needSep" value="true"/>
    </c:if>

    <c:if test="${model.dir.album}">

        <c:if test="${model.user.downloadRole}">
            <sub:url value="download.view" var="downloadUrl">
                <sub:param name="id" value="${model.dir.id}"/>
            </sub:url>
            <c:if test="${needSep}">|</c:if>
            <a href="${downloadUrl}"><fmt:message key="common.download"/></a>
            <c:set var="needSep" value="true"/>
        </c:if>

        <c:if test="${model.user.coverArtRole}">
            <sub:url value="editTags.view" var="editTagsUrl">
                <sub:param name="id" value="${model.dir.id}"/>
            </sub:url>
            <c:if test="${needSep}">|</c:if>
            <a href="${editTagsUrl}"><fmt:message key="main.tags"/></a>
            <c:set var="needSep" value="true"/>
        </c:if>

    </c:if>

    <c:if test="${model.user.commentRole}">
        <c:if test="${needSep}">|</c:if>
        <a href="javascript:toggleComment()"><fmt:message key="main.comment"/></a>
		<c:set var="needSep" value="true"/>
    </c:if>
	
    <c:if test="${model.user.coverArtRole}">
		<c:if test="${needSep}">|</c:if>
        <a href="javascript:toggleMediaType()">MediaType</a>
    </c:if>
</h2>
</c:if>

<c:if test="${model.dir.album}">

    <c:if test="${model.user.searchRole}">

    <div class="detail">
        <c:if test="${not empty model.artist and not empty model.album}">
            <sub:url value="http://www.google.com/search" var="googleUrl" encoding="UTF-8">
                <sub:param name="q" value="\"${model.artist}\" \"${model.album}\""/>
            </sub:url>
            <sub:url value="http://en.wikipedia.org/wiki/Special:Search" var="wikipediaUrl" encoding="UTF-8">
                <sub:param name="search" value="\"${model.album}\""/>
                <sub:param name="go" value="Go"/>
            </sub:url>
            <sub:url value="http://www.discogs.com/search" var="discogsUrl" encoding="UTF-8">
                <sub:param name="q" value="${model.artist}"/>
            </sub:url>
			<sub:url value="http://www.musik-sammler.de/index.php" var="MusiksammlerUrl" encoding="UTF-8">
                <sub:param name="do" value="search"/>
				<sub:param name="artist" value="\"${model.artist}\""/>
            </sub:url>
			<sub:url value="http://www.laut.de/Suche" var="lautUrl" encoding="UTF-8">
                <sub:param name="suchbegriff" value="${model.artist} ${model.album}"/>
            </sub:url>
            <sub:url value="http://www.last.fm/search" var="lastFmUrl" encoding="UTF-8">
                <sub:param name="q" value="\"${model.artist}\" \"${model.album}\""/>
                <sub:param name="type" value="album"/>
            </sub:url>
            <sub:url value="http://www.youtube.com/results" var="YoutubeUrl" encoding="UTF-8">
                <sub:param name="search_query" value="${model.artist}"/>
            </sub:url>
			<span display="inline" class="detailcolor"><fmt:message key="top.search"/></span> 
            <a target="_blank" href="${googleUrl}">Google</a> |
            <a target="_blank" href="${wikipediaUrl}">Wikipedia</a> |
            <a target="_blank" href="${discogsUrl}">Discogs</a> |
            <a target="_blank" href="${MusiksammlerUrl}">MusikSammler</a> |
            <a target="_blank" href="${lautUrl}">Laut</a> |
            <a target="_blank" href="${lastFmUrl}">Last.fm</a> |
            <a target="_blank" href="${YoutubeUrl}">Youtube</a>
        </c:if>
		<br>
	</div>
	</c:if>
  
    <div class="detail" style="padding-top:0.2em">
        <fmt:message key="main.playcount"><fmt:param value="${model.dir.playCount}"/></fmt:message>
        <c:if test="${not empty model.dir.lastPlayed}">
            <fmt:message key="main.lastplayed">
                <fmt:param><fmt:formatDate type="date" dateStyle="long" value="${model.dir.lastPlayed}"/></fmt:param>
            </fmt:message>
        </c:if>
    </div>
        <c:if test="${model.user.commentRole}">
            <c:import url="rating.jsp">
                <c:param name="id" value="${model.dir.id}"/>
                <c:param name="path" value="${model.dir.path}"/>
                <c:param name="readonly" value="false"/>
                <c:param name="rating" value="${model.userRating}"/>
            </c:import>
        </c:if>
		
        <c:if test="${model.user.commentRole}">
            <c:import url="hot.jsp">
                <c:param name="id" value="${model.dir.id}"/>
                <c:param name="flag" value="${model.hotRating}"/>
            </c:import>
        </c:if>		
		
		<c:if test="${model.user.shareRole}">
		<a href="${shareUrl}"><img src="<spring:theme code="shareFacebookImage"/>" alt=""></a>
            <a href="${shareUrl}"><img src="<spring:theme code="shareTwitterImage"/>" alt=""></a>
            <a href="${shareUrl}"><img src="<spring:theme code="shareGooglePlusImage"/>" alt=""></a>
            <a href="${shareUrl}"><span class="detail"><fmt:message key="main.sharealbum"/></span></a> 
        </c:if>
</c:if>

<div id="MediaTypeSwitch" style="display:none">
	<br>
	Here you can manuely override your current MediaFile-Type.<br>
	<br>
		<form method="post" action="setMediaFile.view">
		<input type="hidden" name="id" value="${model.dir.id}">
        <input type="hidden" name="action" value="setmediatype">
		<input type="radio" name="mediatype" value="MULTIARTIST"> MULTIARTIST (Sorting on Title)<br>
		<input type="radio" name="mediatype" value="ARTIST"> ARTIST (Sorting on Year)<br>
		<br>
		<input type="radio" name="mediatype" value="ALBUMSET"> ALBUMSET <br>
		<input type="radio" name="mediatype" value="ALBUM"> ALBUM <br>
		<br>
		<input type="radio" name="mediatype" value="DIRECTORY"> DIRECTORY<br>
		<input type="radio" name="mediatype" value="AUTO"> AUTO<br>
		<br>
		<input type="submit" value="Update">
	<br><br>
	<span class="detailcolor">-- DEBUGINFO --</span><br><br>
	<span class="detailcolordark">Media Id </span>
	<span class="detailcolor">${model.dir.id} </span><br>
	<span class="detailcolordark">Override </span>
	<span class="detailcolor">${model.dir.mediaTypeOverride} </span><br>
	<span class="detailcolordark">MediaType </span>
	<span class="detailcolor">${model.dir.mediaType}</span>	<br>
	<br>
	</form>	
</div>

<div id="comment" class="albumComment"><sub:wiki text="${model.dir.comment}"/></div>

<div id="commentForm" style="display:none">
    <form method="post" action="setMusicFileInfo.view">
		<input type="hidden" name="id" value="${model.dir.id}">	
        <input type="hidden" name="action" value="comment">
        <textarea name="comment" rows="6" cols="70">${model.dir.comment}</textarea>
        <input type="submit" value="<fmt:message key="common.save"/>">
    </form>
    <fmt:message key="main.wiki"/>
</div>

<script type='text/javascript'>
    function toggleComment() {
        $("#commentForm").toggle();
        $("#comment").toggle();
    }
	
    function toggleMediaType() {
        $("#MediaTypeSwitch").toggle();
    }	
</script>


<table cellpadding="10" style="width:100%">
<tr style="vertical-align:top;">
    <td style="vertical-align:top;">
        <table style="border-collapse:collapse;white-space:nowrap">
            <c:set var="cutoff" value="${model.visibility.captionCutoff}"/>
            <c:forEach items="${model.children}" var="child" varStatus="loopStatus">
                <%--@elvariable id="child" type="net.sourceforge.subsonic.domain.MediaFile"--%>
                <c:choose>
                    <c:when test="${loopStatus.count % 2 == 1}">
                        <c:set var="htmlClass" value="class='bgcolor2'"/>
                    </c:when>
                    <c:otherwise>
                        <c:set var="htmlClass" value=""/>
                    </c:otherwise>
				</c:choose>
					
				<c:choose>
				<c:when test="${model.dir.mediaType eq 'MULTIARTIST'}">
					<tr style="margin:0;padding:0;border:0">
                    <c:import url="playAddDownload.jsp">
                        <c:param name="id" value="${child.id}"/>
                        <c:param name="video" value="false"/>
                        <c:param name="playEnabled" value="${model.user.streamRole and not model.partyMode}"/>
                        <c:param name="playAddEnabled" value="false"/>
                        <c:param name="addEnabled" value="false"/>
                        <c:param name="downloadEnabled" value="false"/>
                        <c:param name="artist" value="${fn:escapeXml(child.artist)}"/>
                        <c:param name="title" value="${child.title}"/>
                        <c:param name="starEnabled" value="true"/>
                        <c:param name="starred" value="${not empty child.starredDate}"/>
                        <c:param name="asTable" value="true"/>
                        <c:param name="YoutubeEnabled" value="false"/>
                    </c:import>
                    </c:when>
                    <c:otherwise>
					<tr style="margin:0;padding:0;border:0">
                    <c:import url="playAddDownload.jsp">
                        <c:param name="id" value="${child.id}"/>
                        <c:param name="video" value="${child.video and model.player.web}"/>
                        <c:param name="playEnabled" value="${model.user.streamRole and not model.partyMode}"/>
                        <c:param name="playAddEnabled" value="${model.user.streamRole and not model.partyMode}"/>
                        <c:param name="addEnabled" value="${model.user.streamRole and (not model.partyMode or not child.directory)}"/>
                        <c:param name="downloadEnabled" value="${model.user.downloadRole and not model.partyMode}"/>
                        <c:param name="artist" value="${fn:escapeXml(child.artist)}"/>
                        <c:param name="title" value="${child.title}"/>
                        <c:param name="starEnabled" value="true"/>
                        <c:param name="starred" value="${not empty child.starredDate}"/>
                        <c:param name="asTable" value="true"/>
                        <c:param name="YoutubeEnabled" value="${not model.user.searchRole}"/>
                        </c:import>
                    </c:otherwise>
                </c:choose>

                    <c:choose>
                        <c:when test="${child.directory}">
                            <sub:url value="main.view" var="childUrl">
                                <sub:param name="id" value="${child.id}"/>
                            </sub:url>

							<td style="padding-left:0.5em" colspan="1">
								<c:if test="${child.mediaType eq 'ALBUMSET'}">
									<img id="cdImage" src="<spring:theme code="CDImage"/>" alt="Albumset">
								</c:if>									
							</td>
							
							<c:choose>
								<c:when test="${model.showAlbumYear}">
									<td style="padding-left:0.50em">
									<span class="detail"><c:if test="${not empty child.year}">[${child.year}]</c:if></span></td>
								</c:when>
								<c:otherwise>
								</c:otherwise>
							</c:choose>

							<c:if test="${not empty child.year}">
								<c:if test="${not empty child.albumSetName}">
									<td style="padding-left:0.5em" colspan="5">
										<a href="${childUrl}" title="${child.albumSetName}"><span style="white-space:nowrap;"><str:truncateNicely upper="${cutoff}">${child.albumSetName}</str:truncateNicely></span></a>
									</td>
								</c:if>
								<c:if test="${not empty child.albumName and empty child.albumSetName}">
									<td style="padding-left:0.5em" colspan="5">
										<a href="${childUrl}" title="${child.albumName}"><span style="white-space:nowrap;"><str:truncateNicely upper="${cutoff}">${child.albumSetName}</str:truncateNicely></span></a>
									</td>
								</c:if>
							</c:if>

							<c:if test="${empty child.year}">
								<c:if test="${not empty child.name}">
									<td style="padding-left:0.5em" colspan="5">
										<a href="${childUrl}" title="${child.albumSetName}"><span style="white-space:nowrap;"><str:truncateNicely upper="${cutoff}">${child.name}</str:truncateNicely></span></a>
									</td>
								</c:if>
							</c:if>
						</c:when>

                        <c:otherwise>
                            <td ${class} style="padding-left:0.25em"><input type="checkbox" class="checkbox" id="songIndex${loopStatus.count - 1}">
                                <span id="songId${loopStatus.count - 1}" style="display: none">${child.id}</span></td>

                            <c:if test="${model.visibility.trackNumberVisible}">
                                <td ${htmlClass} style="padding-right:0.5em;text-align:right">
                                    <span class="detail">${child.trackNumber}</span>
                                </td>
                            </c:if>

                            <td ${htmlClass} style="padding-right:1.25em;white-space:nowrap">
                                <span title="${child.title}"><str:truncateNicely upper="${cutoff}">${fn:escapeXml(child.title)}</str:truncateNicely></span>
                            </td>

                            <c:if test="${model.visibility.albumVisible}">
                                <td ${htmlClass} style="padding-right:1.25em;white-space:nowrap">
                                    <span class="detail" title="${child.albumName}"><str:truncateNicely upper="${cutoff}">${fn:escapeXml(child.albumName)}</str:truncateNicely></span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.artistVisible and model.multipleArtists}">
                                <td ${htmlClass} style="padding-right:1.25em;white-space:nowrap">
                                    <span class="detail" title="${child.artist}"><str:truncateNicely upper="${cutoff}">${fn:escapeXml(child.artist)}</str:truncateNicely></span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.genreVisible}">
                                <td ${htmlClass} style="padding-right:1.25em;white-space:nowrap">
                                    <span class="detail">${child.genre}</span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.yearVisible}">
                                <td ${htmlClass} style="padding-right:1.25em">
                                    <span class="detail">${child.year}</span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.formatVisible}">
                                <td ${htmlClass} style="padding-right:1.25em">
                                    <span class="detail">${fn:toLowerCase(child.format)}</span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.fileSizeVisible}">
                                <td ${htmlClass} style="padding-right:1.25em;text-align:right">
                                    <span class="detail"><sub:formatBytes bytes="${child.fileSize}"/></span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.durationVisible}">
                                <td ${htmlClass} style="padding-right:1.25em;text-align:right">
                                    <span class="detail">${child.durationString}</span>
                                </td>
                            </c:if>

                            <c:if test="${model.visibility.bitRateVisible}">
                                <td ${htmlClass} style="padding-right:0.25em">
                                    <span class="detail">
                                        <c:if test="${not empty child.bitRate}">
                                            ${child.bitRate} Kbps ${child.variableBitRate ? "vbr" : ""}
                                        </c:if>
                                        <c:if test="${child.video and not empty child.width and not empty child.height}">
                                            (${child.width}x${child.height})
                                        </c:if>
                                    </span>
                                </td>
                            </c:if>


                        </c:otherwise>
                    </c:choose>
                </tr>
            </c:forEach>
        </table>
    </td>

	
    <td style="vertical-align:top;width:100%">
        <c:forEach items="${model.coverArts}" var="coverArt" varStatus="loopStatus">
		
		<!--		
        <div style="float:left; padding:5px">

		<c:choose>
		<c:when test="${coverArt eq model.album }">
            <div class="artistbanner" style="padding:5px;">
		</c:when>
		<c:otherwise>
            <div style="float:left; padding:5px">
		</c:otherwise>
		</c:choose>
		-->
		
		<c:choose>
		<c:when test="${coverArt eq model.dir or coverArt eq model.album}">
            <div style="padding:5px;">
		</c:when>
		<c:otherwise>
            <div style="float:left; padding:5px">
		</c:otherwise>
		</c:choose>	
		
                <c:import url="coverArt.jsp">
                    <c:param name="albumId" value="${coverArt.id}"/>
                    <c:param name="albumName" value="${coverArt.name}"/>
                    <c:param name="coverArtSize" value="${model.coverArtSize}"/>
                    <c:param name="showLink" value="${coverArt ne model.dir}"/>
                    <c:param name="showZoom" value="${coverArt eq model.dir}"/>
                    <c:param name="showChange" value="${(coverArt eq model.dir) and model.user.coverArtRole}"/>
                    <c:param name="showCaption" value="true"/>
                    <c:param name="appearAfter" value="${loopStatus.count * 30}"/>
                </c:import>
            </div>
        </c:forEach>
		
	<c:if test="${model.multipleArtists}">
	</c:if>

	<c:if test="${model.showGenericCoverArt}">
	<div style="float:left; padding:5px">
		<c:import url="coverArt.jsp">
			<c:param name="albumId" value="${model.dir.id}"/>
			<c:param name="coverArtSize" value="${model.coverArtSize}"/>
			<c:param name="showLink" value="false"/>
			<c:param name="showZoom" value="false"/>
			<c:param name="showChange" value="${model.user.coverArtRole}"/>
			<c:param name="appearAfter" value="0"/>
		</c:import>
	</div>
	</c:if>
    </td>
	
    <td style="vertical-align:top;">
        <div style="padding:0 1em 0 1em;">
            <c:if test="${not empty model.ad}">
                <div class="detail" style="text-align:center">
                        ${model.ad}
                    <br/>
                    <br/>
                    <sub:url value="donate.view" var="donateUrl">
                        <sub:param name="path" value="${model.dir.path}"/>
                    </sub:url>
                    <fmt:message key="main.donate"><fmt:param value="${donateUrl}"/><fmt:param value="${model.brand}"/></fmt:message>
                </div>
            </c:if>
        </div>
    </td>
</tr>
</table>

<select id="moreActions" onchange="actionSelected(this.options[selectedIndex].id);" style="margin-bottom:1.0em">
    <option id="top" selected="selected"><fmt:message key="main.more"/></option>
    <option style="color:blue;"><fmt:message key="main.more.selection"/></option>
    <option id="selectAll">&nbsp;&nbsp;&nbsp;&nbsp;<fmt:message key="playlist.more.selectall"/></option>
    <option id="selectNone">&nbsp;&nbsp;&nbsp;&nbsp;<fmt:message key="playlist.more.selectnone"/></option>
    <c:if test="${model.user.shareRole}">
        <option id="share">&nbsp;&nbsp;&nbsp;&nbsp;<fmt:message key="main.more.share"/></option>
    </c:if>
    <c:if test="${model.user.downloadRole}">
        <option id="download">&nbsp;&nbsp;&nbsp;&nbsp;<fmt:message key="common.download"/></option>
    </c:if>
    <option id="appendPlaylist">&nbsp;&nbsp;&nbsp;&nbsp;<fmt:message key="playlist.append"/></option>
</select>

<div style="padding-bottom: 1em">
    <c:if test="${not empty model.previousAlbum}">
        <sub:url value="main.view" var="previousUrl">
            <sub:param name="id" value="${model.previousAlbum.id}"/>
        </sub:url>
        <div class="back" style="float:left;padding-right:10pt"><a href="${previousUrl}" title="${model.previousAlbum.name}">
            <str:truncateNicely upper="55">${fn:escapeXml(model.previousAlbum.name)}</str:truncateNicely>
        </a></div>
    </c:if>
    <c:if test="${not empty model.nextAlbum}">
        <sub:url value="main.view" var="nextUrl">
            <sub:param name="id" value="${model.nextAlbum.id}"/>
		</sub:url>
        <div class="forwardright" style="float:left"><a href="${nextUrl}" title="${model.nextAlbum.name}">
            <str:truncateNicely upper="55">${fn:escapeXml(model.nextAlbum.name)}</str:truncateNicely>
        </a></div>
    </c:if>
</div>

<div id="dialog-select-playlist" title="<fmt:message key="main.addtoplaylist.title"/>" style="display: none;">
    <p><fmt:message key="main.addtoplaylist.text"/></p>
    <div id="dialog-select-playlist-list"></div>
</div>

<!-- CONTENT -->
</div>

</body>

<c:if test="${model.customScrollbar}">
<script type="text/javascript">        
(function($){
	$(window).load(function(){
		$("#content_2").mCustomScrollbar({
			set_width:false, /*optional element width: boolean, pixels, percentage*/
			set_height:false, /*optional element height: boolean, pixels, percentage*/
			horizontalScroll:false, /*scroll horizontally: boolean*/
			scrollInertia:400, /*scrolling inertia: integer (milliseconds)*/
			scrollEasing:"easeOutCubic", /*scrolling easing: string*/
			mouseWheel:"auto", /*mousewheel support and velocity: boolean, "auto", integer*/
			autoDraggerLength:true, /*auto-adjust scrollbar dragger length: boolean*/
			scrollButtons:{ /*scroll buttons*/
				enable:true, /*scroll buttons support: boolean*/
				scrollType:"pixels", /*scroll buttons scrolling type: "continuous", "pixels"*/
				scrollSpeed:45, /*scroll buttons continuous scrolling speed: integer*/
				scrollAmount:250 /*scroll buttons pixels scroll amount: integer (pixels)*/
			},
			advanced:{
				updateOnBrowserResize:true, /*update scrollbars on browser resize (for layouts based on percentages): boolean*/
				updateOnContentResize:true, /*auto-update scrollbars on content resize (for dynamic content): boolean*/
				autoExpandHorizontalScroll:false /*auto expand width for horizontal scrolling: boolean*/
			},
			callbacks:{
				onScroll:function(){}, /*user custom callback function on scroll event*/
				onTotalScroll:function(){}, /*user custom callback function on bottom reached event*/
				onTotalScrollOffset:0 /*bottom reached offset: integer (pixels)*/
			}
		});
	});
})(jQuery);

$(".content_main").resize(function(e){
	$(".content_main").mCustomScrollbar("update");
});
</script>
</c:if>	
</html>
