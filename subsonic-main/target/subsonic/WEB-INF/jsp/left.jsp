<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head>
	<%@ include file="head.jsp" %>
	<%@ include file="jquery.jsp" %> 

    <c:if test="${model.customScrollbar}">
	<style type="text/css">
		.content{position:absolute; left:0px; top:0px; margin:1; width:92%; height:99%; padding:0 10px; border-bottom:1px solid #333;overflow:auto;}
	</style>
    </c:if>	

    <c:if test="${not model.customScrollbar}">
	<style type="text/css">
		.content{position:absolute; left:0px; top:0px; margin:1; margin-top:85px; width:90%; height:90%; padding:0 10px;}
	</style>
    <script type="text/javascript" src="<c:url value="/script/smooth-scroll.js"/>"></script>
    </c:if>	

    <c:if test="${model.customScrollbar}">
	<script type="text/javascript" src="<c:url value="/script/jquery.mousewheel.min.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/script/jquery.mCustomScrollbar.js"/>"></script>
    </c:if>	

	<script type="text/javascript" src="<c:url value="/script/scripts.js"/>"></script> 
	<script type="text/javascript" src="<c:url value="/dwr/engine.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/dwr/interface/playlistService.js"/>"></script>

	<script type="text/javascript" language="javascript">
        var playlists;

        function init() {
            dwr.engine.setErrorHandler(null);
            updatePlaylists();
        }

        function updatePlaylists() {
            playlistService.getReadablePlaylists(playlistCallback);
        }

        function createEmptyPlaylist() {
            playlistService.createEmptyPlaylist(playlistCallback);
            $("#playlists").show();
        }

        function hideAllPlaylists() {
            $('#playlistOverflow').hide('blind');
            $("#playlists").hide('blind');
            $('#hideAllPlaylists').hide('blind');
            $('#showAllPlaylists').hide('blind');
            $('#showsomePlaylists').show('blind');
		}
		
        function showAllPlaylists() {
            $("#playlists").show();
            $('#playlistOverflow').show('blind');
            $('#hideAllPlaylists').show('blind');			
            $('#showAllPlaylists').hide('blind');
            $('#showsomePlaylists').hide('blind');
        }

        function showsomePlaylists() {
            $('#playlistOverflow').hide('blind');
            $("#playlists").show('blind');
            $('#hideAllPlaylists').show('blind');			
            $('#showAllPlaylists').show('blind');
            $('#showsomePlaylists').hide('blind');
        }
		
        function playlistCallback(playlists) {
            this.playlists = playlists;
			
            $("#playlists").empty();
            $("#playlistOverflow").empty();
			
            for (var i = 0; i < playlists.length; i++) {
                var playlist = playlists[i];
                var overflow = i > 9;
                $("<p class='dense'><a target='main' href='playlist.view?id=" +
                playlist.id + "'>" + playlist.name + "&nbsp;(" + playlist.fileCount + ")</a></p>").appendTo(overflow ? "#playlistOverflow" : "#playlists");
            }

            if (playlists.length > 9 && !$('#playlistOverflow').is(":visible")) {
			    $("#playlists").hide();
				$("#playlistOverflow").hide();			
                $('#showAllPlaylists').show();
				$('#showsomePlaylists').show();
            }
			
            if (playlists.length < 9 ) {
			    $("#playlists").hide();
				$("#playlistOverflow").hide();
				$('#showAllPlaylists').hide();
				$('#showsomePlaylists').show('blind');
            }			
        }
    </script>
</head>
<body class="bgcolor2 leftframe" onload="init()">
<c:if test="${not model.customScrollbar}">
<a name="top"></a>
</c:if>	
<!-- content block -->
<div id="content_1" class="content">

	<!-- CONTENT -->
	<div class="bgcolor2" style="opacity: 1.0; clear: both; position: fixed; top: 0; right: 0; left: 0;
	padding: 0.25em 0.15em 0.15em 0.15em; max-width: 250px; border-bottom: 1px solid black;">
		<Table>
		<tr>
			<td style="padding-left:0em; padding-bottom:0em;">
				<form method="post" action="search.view" target="main" name="searchForm">
					<table><tr>
						<td><input type="text" name="query" id="query" size="24" value="${search}" onclick="select();"></td>
						<td><a href="javascript:document.searchForm.submit()"><img src="<spring:theme code="searchImage"/>" alt="${search}" title="${search}"></a></td>
					</tr></table>
				</form>
			</td>
		</tr>
		</table>

	<c:choose>
		<c:when test="${model.scanning}">
	<!--<div style="padding-bottom:1.0em">
		<div class="warning"><fmt:message key="left.scanning"/></div>
		<div class="forward"><a href="left.view"><fmt:message key="common.refresh"/></a></div>
	</div>-->
		<div style="padding-bottom:0.25em">
			<div class="forward"><a href="left.view?refresh=true"><fmt:message key="common.refresh"/></a></div>
		</div>
		</c:when>
		<c:otherwise>
			<div style="padding-bottom:0.25em">
				<div class="forward"><a href="left.view?refresh=true"><fmt:message key="common.refresh"/></a></div>
			</div>
		</c:otherwise>
	</c:choose>		

	</div>
	
    <c:if test="${model.customScrollbar}">
	<a id="top"></a>
    </c:if>		
	<div style="padding-bottom:1.0em">
	<c:if test="${model.customScrollbar}">
		<div id="anchor_list">
		<c:forEach items="${model.indexes}" var="index">
			<c:choose>
				<c:when test="${index.index eq '#'}">
					<a href="#" lnk="0">${index.index}</a>
				</c:when>
				<c:when test="${index.index eq '!'}">
					<a href="#" lnk="1">${index.index}</a>
				</c:when>
				<c:otherwise>
					<a href="#" lnk="${index.index}">${index.index}</a>
				</c:otherwise>
			</c:choose>
		</c:forEach>
		</div>
	</c:if>	
	
	<c:if test="${not model.customScrollbar}">
		<c:forEach items="${model.indexes}" var="index">
			<a href="#${index.index}" accesskey="${index.index}">${index.index}</a>
		</c:forEach>
    </c:if>	
	</div>
	
	
	<c:if test="${model.statistics.songCount gt 0}">
		<div class="detail">
			<fmt:message key="left.statistics">
				<fmt:param value="${model.statistics.artistCount}"/>
				<fmt:param value="${model.statistics.albumCount}"/>
				<fmt:param value="${model.statistics.songCount}"/>
				<fmt:param value="${model.bytes}"/>
				<fmt:param value="${model.hours}"/>
			</fmt:message>
		</div>
	</c:if>
	
	<c:if test="${fn:length(model.musicFolders) > 1}">
		<div style="padding-top:1em">
			<select name="musicFolderId" style="width:100%" onchange="location='left.view?musicFolderId=' + options[selectedIndex].value;" >
				<option value="-1"><fmt:message key="left.allfolders"/></option>
				<c:forEach items="${model.musicFolders}" var="musicFolder">
					<option ${model.selectedMusicFolder.id == musicFolder.id ? "selected" : ""} value="${musicFolder.id}">${musicFolder.name}</option>
				</c:forEach>
			</select>
		</div>
	</c:if>

	<c:if test="${not empty model.shortcuts}">
		<h2 class="bgcolor1"><fmt:message key="left.shortcut"/></h2>
		<c:forEach items="${model.shortcuts}" var="shortcut">
			<p class="dense" style="padding-left:0.5em">
				<sub:url value="main.view" var="mainUrl">
					<sub:param name="id" value="${shortcut.id}"/>
				</sub:url>
				<a target="main" href="${mainUrl}">${shortcut.name}</a>
			</p>
		</c:forEach>
	</c:if>

	<h2 class="bgcolor1"><fmt:message key="left.playlists"/></h2>
	<div id="playlistWrapper" style='padding-left:0.5em'>
		<div id="playlists"></div>
		<div id="playlistOverflow" style="display:none"></div>
		<div style="padding-top: 0.3em"/>
		<div id="showsomePlaylists" style="display: none"><a href="javascript:noop()" onclick="showsomePlaylists()"><fmt:message key="left.showsomeplaylists"/></a></div>
		<div id="showAllPlaylists" style="display: none"><a href="javascript:noop()" onclick="showAllPlaylists()"><fmt:message key="left.showallplaylists"/></a></div>
		<div id="hideAllPlaylists" style="display: none"><a href="javascript:noop()" onclick="hideAllPlaylists()"><fmt:message key="left.hideallplaylists"/></a></div>
		<div><a href="javascript:noop()" onclick="createEmptyPlaylist()"><fmt:message key="left.createplaylist"/></a></div>
		<div><a href="importPlaylist.view" target="main"><fmt:message key="left.importplaylist"/></a></div>
	</div>

	<c:if test="${not empty model.radios}">
		<h2 class="bgcolor1"><fmt:message key="left.radio"/></h2>
		<c:forEach items="${model.radios}" var="radio">
			<p class="dense">
				<a target="hidden" href="${radio.streamUrl}">
					<img src="<spring:theme code="playImage"/>" alt="<fmt:message key="common.play"/>" title="<fmt:message key="common.play"/>"></a>
				<c:choose>
					<c:when test="${empty radio.homepageUrl}">
						${radio.name}
					</c:when>
					<c:otherwise>
						<a target="main" href="${radio.homepageUrl}">${radio.name}</a>
					</c:otherwise>
				</c:choose>
			</p>
		</c:forEach>
	</c:if>

	<c:forEach items="${model.indexedArtists}" var="entry">
		<table class="bgcolor1" style="width:100%;padding:0;margin:1em 0 0 0;border:0">
			<tr style="padding:0;margin:0;border:0">
			
				<c:if test="${model.customScrollbar}">
					<th style="text-align:left;padding:0;margin:0;border:0">
					<c:choose>
						<c:when test="${entry.key.index eq '#'}">
							<a id="0"></a>
						</c:when>
						<c:when test="${entry.key.index eq '!'}">
							<a id="1"></a>
						</c:when>
						<c:otherwise>
							<a id="${entry.key.index}"></a>
						</c:otherwise>
					</c:choose>
					<h2 style="padding:0;margin:0;border:0">${entry.key.index}</h2>
					</th>
				</c:if>		

				<c:if test="${not model.customScrollbar}">
					<th style="text-align:left;padding:0;margin:0;border:0"><a name="${entry.key.index}"></a>
					<h2 style="padding:0;margin:0;border:0">${entry.key.index}</h2>
					</th>
				</c:if>						
				
				<th style="text-align:right;">
					<c:if test="${not model.customScrollbar}">
						<a href="#top"><img src="<spring:theme code="upImage"/>" alt=""></a>
					</c:if>	
					<c:if test="${model.customScrollbar}">
						<a href="#" class="back_to_top"><img src="<spring:theme code="upImage"/>" alt=""></a>
					</c:if>	
				</th>
			</tr>
		</table>

		<c:forEach items="${entry.value}" var="artist">
			<p class="dense" style="padding-left:0.5em">
				<span title="${artist.name}">
					<sub:url value="main.view" var="mainUrl">
						<c:choose>
							<c:when test="${model.organizeByFolderStructure}">
								<c:forEach items="${artist.mediaFiles}" var="mediaFile">
							<sub:param name="id" value="${mediaFile.id}"/>
								</c:forEach>
							</c:when>
							<c:otherwise>
								<sub:param name="id" value="${artist.id}"/>
								</c:otherwise>
						</c:choose>
					</sub:url>
					<a target="main" href="${mainUrl}"><str:truncateNicely upper="${model.captionCutoff}">${artist.name}</str:truncateNicely></a>
				</span>
			</p>
		</c:forEach>
	</c:forEach>

	<div style="padding-top:1em"></div>

	<c:forEach items="${model.singleSongs}" var="song">
		<p class="dense" style="padding-left:0.5em">
			<span title="${song.title}">
				<c:import url="playAddDownload.jsp">
					<c:param name="id" value="${song.id}"/>
					<c:param name="playEnabled" value="${model.user.streamRole and not model.partyMode}"/>
					<c:param name="addEnabled" value="${model.user.streamRole}"/>
					<c:param name="downloadEnabled" value="${model.user.downloadRole and not model.partyMode}"/>
					<c:param name="video" value="${song.video and model.player.web}"/>
				</c:import>
				<str:truncateNicely upper="${model.captionCutoff}">${song.title}</str:truncateNicely>
			</span>
		</p>
	</c:forEach>

	<div style="height:5em"></div>

	<div class="bgcolor2" style="opacity: 1.0; clear: both; position: fixed; bottom: 0; right: 0; left: 0;
		padding: 0.25em 0.75em 0.25em 0.75em; border-top:1px solid black; max-width: 650px;">

		<c:if test="${not model.customScrollbar}">
		<a href="#top">TOP</a>
		</c:if>	

		<c:if test="${model.customScrollbar}">
		<a class="back_to_top" href="#">TOP</a>
		<div id="anchor_list" style="display: inline">
		<c:forEach items="${model.indexes}" var="index">
				<c:choose>
					<c:when test="${index.index eq '#'}">
						<a href="#" lnk="0">${index.index}</a>
					</c:when>
					<c:when test="${index.index eq '!'}">
						<a href="#" lnk="1">${index.index}</a>
					</c:when>
					<c:otherwise>
						<a href="#" lnk="${index.index}">${index.index}</a>
					</c:otherwise>
				</c:choose>
			</c:forEach>
		</div>	
		</c:if>	
			
		<c:if test="${not model.customScrollbar}">
			<c:forEach items="${model.indexes}" var="index">
				<a href="#${index.index}">${index.index}</a>
			</c:forEach>
		</c:if>	
			

	</div>
	<!-- CONTENT -->
</div>
 
<c:if test="${model.customScrollbar}">
	<script>
		(function($){
			$(window).load(function(){
				$("#content_1").mCustomScrollbar({
					set_width:false, /*optional element width: boolean, pixels, percentage*/
					set_height:false, /*optional element height: boolean, pixels, percentage*/
					horizontalScroll:false, /*scroll horizontally: boolean*/
					scrollInertia:450, /*scrolling inertia: integer (milliseconds)*/
					scrollEasing:"easeOutCubic", /*scrolling easing: string*/
					mouseWheel:2, /*mousewheel support and velocity: boolean, "auto", integer*/
					autoDraggerLength:true, /*auto-adjust scrollbar dragger length: boolean*/
					scrollButtons:{ /*scroll buttons*/
						enable:true, /*scroll buttons support: boolean*/
						scrollType:"pixels", /*scroll buttons scrolling type: "continuous", "pixels"*/
						scrollSpeed:25, /*scroll buttons continuous scrolling speed: integer*/
						scrollAmount:200 /*scroll buttons pixels scroll amount: integer (pixels)*/
					},
					advanced:{
						updateOnBrowserResize:true, /*update scrollbars on browser resize (for layouts based on percentages): boolean*/
						updateOnContentResize:true, /*auto-update scrollbars on content resize (for dynamic content): boolean*/
						autoExpandHorizontalScroll:false /*auto expand width for horizontal scrolling: boolean*/
					}
				});
			});
		})(jQuery);
		
	$('#anchor_list > a').click(function(){
		var myPos = $(this).index()+0; /* pick the list position of the element clicked in our sidebar links collection */
		id = $(this).attr("lnk"); 
		var thisPos = $("#"+id).position(); /*	get the  position of the corresponding paragraph */
		var poslnk = thisPos.top.toFixed(0);
		$(".content").mCustomScrollbar("scrollTo", thisPos.top );
	});

	$(".back_to_top").click(function() {
		$(".content").scrollTop();
		$(".content").mCustomScrollbar("scrollTo","top");
		});	
	</script>
</c:if>	

<c:if test="${not model.customScrollbar}">
	<script>
	$(".back_to_top").click(function() {
		$(".content").scrollTop();
		}) (jQuery);	
	</script>
</c:if>	


</body>
</html>