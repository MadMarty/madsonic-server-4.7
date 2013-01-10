<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html><head>
    <%@ include file="head.jsp" %>

	<script type="text/javascript" src="<c:url value="/script/prototype.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/script/scripts.js"/>"></script>	
	<script type="text/javascript" src="<c:url value="/dwr/engine.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/dwr/util.js"/>"></script>
	<script type="text/javascript" src="<c:url value="/dwr/interface/nowPlayingService.js"/>"></script>	
	
    <script type="text/javascript" language="javascript">

	startGetNowPlayingTimer();
	
	function startGetNowPlayingTimer() {
		nowPlayingService.getNowPlaying(getNowPlayingCallback);
		setTimeout("startGetNowPlayingTimer()", 30000);
	}	
		
	function newwindow() {
	<!--hide
		window.open('moree.view?','jav','width=750,height=250,resizable=no,scrollbars=yes,toolbar=no,status=yes');
	}
	//-->
	</SCRIPT>
</head>

<body class="bgcolor2 topframe" style="margin:0.4em 1em 0.4em 1em">

<fmt:message key="top.home" var="home"/>
<fmt:message key="top.now_playing" var="nowPlaying"/>
<fmt:message key="top.starred" var="starred"/>
<fmt:message key="top.settings" var="settings"/>
<fmt:message key="top.status" var="status"/>
<fmt:message key="top.podcast" var="podcast"/>
<fmt:message key="top.more" var="more"/>
<fmt:message key="top.chat" var="chat"/>
<fmt:message key="top.help" var="help"/>
<fmt:message key="top.search" var="search"/>

<c:if test="${not model.showRight}">			
<div id="scanningStatus" class="warning" style="position: absolute; height: auto; width: 200px; left: 10px; top: 55px; border:1 solid white;">
	<img src="<spring:theme code="scanningImage"/>" title="" alt=""> <fmt:message key="main.scanning"/> <span id="scanCount"></span>
</div>		

    <script type="text/javascript">
        startGetScanningStatusTimer();

        function startGetScanningStatusTimer() {
            nowPlayingService.getScanningStatus(getScanningStatusCallback);
        }
		
        function getScanningStatusCallback(scanInfo) {
            dwr.util.setValue("scanCount", scanInfo.count);
            if (scanInfo.scanning) {
                $("scanningStatus").show();
                setTimeout("startGetScanningStatusTimer()", 1000);
            } else {
                $("scanningStatus").hide();
                setTimeout("startGetScanningStatusTimer()", 15000);
            }
        }
    </script>
</c:if>

<table style="margin:0"><tr valign="middle">
    <td class="logo" style="padding-right:2em"><a href="help.view?" target="main"><img src="<spring:theme code="logoImage"/>" title="${help}" alt=""></a></td>

    <c:if test="${not model.musicFoldersExist}">
        <td style="padding-right:2em">
            <p class="warning"><fmt:message key="top.missing"/></p>
        </td>
    </c:if>

    <td>
        <table><tr align="center">
            <td style="min-width:4em;padding-right:1.0em;padding-left:2.2em">
				<sub:url value="home.view" var="homeUrl">
					<sub:param name="listType" value="${model.listType}"/>
					<sub:param name="listRows" value="${model.listRows}"/>
					<sub:param name="listColumns" value="${model.listColumns}"/>
				</sub:url>
				<a href="${homeUrl}" target="main"><img src="<spring:theme code='homeImage'/>" title="${home}" alt="${home}"/></a><br>
				<a href="${homeUrl}" target="main">${home}</a>
           </td>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="nowPlaying.view?" target="main"><img src="<spring:theme code="nowPlayingImage"/>" title="${nowPlaying}" alt="${nowPlaying}"></a><br>
                <a href="nowPlaying.view?" target="main">${nowPlaying}</a>
            </td>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="starred.view?" target="main"><img src="<spring:theme code="starOnImage"/>" title="${starred}" alt="${starred}"></a><br>
                <a href="starred.view?" target="main">${starred}</a>
            </td>
			<!--
			<td style="min-width:4em;padding-right:1.0em">
				<a href="genres.view?" target="main"><img src="<spring:theme code="genresImage"/>" title="Genres" alt="Genres"></a><br>
				<a href="genres.view?" target="main">Genres</a>
			</td>
			<td style="min-width:4em;padding-right:1.0em">
				<a href="genres.view?" target="main"><img src="<spring:theme code="moodsImage"/>" title="Moods" alt="Moods"></a><br>
				<a href="genres.view?" target="main">Moods</a>
			</td>
			-->
			<td style="min-width:4em;padding-right:1.0em">
				<a href="radio.view?" target="main"><img src="<spring:theme code="radioImage"/>" title="Radio" alt="Radio"></a><br>
				<a href="radio.view?" target="main">Radio</a>
			</td>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="podcastReceiver.view?" target="main"><img src="<spring:theme code="podcastLargeImage"/>" title="${podcast}" alt="${podcast}"></a><br>
                <a href="podcastReceiver.view?" target="main">${podcast}</a>
            </td>
            <c:if test="${model.user.settingsRole}">
                <td style="min-width:4em;padding-right:1.0em">
                    <a href="settings.view?" target="main"><img src="<spring:theme code="settingsImage"/>" title="${settings}" alt="${settings}"></a><br>
                    <a href="settings.view?" target="main">${settings}</a>
                </td>
            </c:if>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="status.view?" target="main"><img src="<spring:theme code="statusImage"/>" title="${status}" alt="${status}"></a><br>
                <a href="status.view?" target="main">${status}</a>
            </td>
            <c:if test="${not model.showRight}">			
            <td style="min-width:4em;padding-right:1.0em">
                <a href="chat.view?" target="main"><img src="<spring:theme code="chatImage"/>" title="${chat}" alt="${chat}"></a><br>
                <a href="chat.view?" target="main">${chat}</a>
            </td>
            </c:if>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="statistics.view?" target="main"><img src="<spring:theme code="chartImage"/>" title="Stats" alt="Statistics"></a><br>
                <a href="statistics.view?" target="main">Statistics</a>
            </td>
			<!--
            <td style="min-width:4em;padding-right:1.0em">
                <a href="home.view?listSize=100&listType=highest" target="main"><img src="icons/TOP100.png" title="TOP100" alt="TOP100"></a><br>
                <a href="home.view?listSize=100&listType=highest" target="main">TOP100</a>
            </td>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="home.view?listSize=100&listType=newest" target="main"><img src="icons/NEW100.png" title="NEW100" alt="NEW100"></a><br>
                <a href="home.view?listSize=100&listType=newest" target="main">NEW100</a>
            </td>
			-->
            <td style="min-width:4em;padding-right:1.0em">
                <a href="loadPlaylist.view?" target="main"><img src="<spring:theme code="playlistImage"/>" title="Playlists" alt="Playlists"></a><br>
                <a href="loadPlaylist.view?" target="main">Playlists</a>
            </td>
			
			<td style="min-width:4em;padding-right:1.0em">
                <a href="more.view?" target="main"><img src="<spring:theme code="moreImage"/>" title="${more}" alt="${more}"></a><br>
                <a href="more.view?" target="main">${more}</a>
            </td>
            <td style="min-width:4em;padding-right:1.0em">
                <a href="help.view?" target="main"><img src="<spring:theme code="helpImage"/>" title="${help}" alt="${help}"></a><br>
                <a href="help.view?" target="main">${help}</a>
            </td>
			<c:if test="${model.user.adminRole}">
                <td style="min-width:4em;padding-right:1.0em">
                    <a href="db.view?" target="_blank"><img src="<spring:theme code="dbImage"/>" title="DB" alt="Database"></a><br>
                    <a href="db.view?" target="_blank">DB</a>
                </td>
				
                <td style="min-width:4em;padding-right:1.0em">
                    <a href="log.view?" target="main"><img src="<spring:theme code="logsImage"/>" title="Logs" alt="Logfiles"></a><br>
                    <a href="log.view?" target="main">Logs</a>
                </td>
				
            </c:if>
			
			<c:if test="${model.user.uploadRole}">
			    <td style="width:4em;padding-right:1.0em"> <A HREF="javascript:newwindow()" ><img src="<spring:theme code="loadImage_mini"/>" title="Upload"/>Upload</a></td>
			</c:if>

            <td style="padding-left:5pt;text-align:center;">
                <p class="detail" style="line-height:1.5">
                    <a href="j_acegi_logout" target="_top"><img src="<spring:theme code="logoffImage"/>" title="<fmt:message key="top.logout"><fmt:param value="${model.user.username}"/></fmt:message>" alt="<fmt:message key="top.logout"><fmt:param value="${model.user.username}"/></fmt:message>"></a>
                    <c:if test="${not model.licensed}">
                        <br>
                        <a href="donate.view" target="main"><img src="<spring:theme code="donateSmallImage"/>" alt=""></a>
                        <a href="donate.view" target="main"><fmt:message key="donate.title"/></a>
                    </c:if>
                </p>
            </td>
	
			<!--
				<td>
				<table><tr align="middle">
				<td style="min-width:4em;padding-left: 2em; padding-right:2.5em">
				<embed src="http://www.adamdorman.com/flash/flip_clock_black_24_w-secs.swf" width="100" height="32" type="application/x-shockwave-flash"  wmode="opaque" quality="high"></embed>
				</td><tr>
				<td style="min-width:4em;padding-right:1.5em">			
			-->			
            <c:if test="${model.newVersionAvailable}">
                <td style="padding-left:15pt">
                    <p class="warning">
                        <fmt:message key="top.upgrade"><fmt:param value="${model.brand}"/><fmt:param value="${model.latestVersion}"/></fmt:message>
                    </p>
                </td>
            </c:if>
        </tr></table>
    </td>

</tr></table>

</body></html>