<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>

<html><head>
    <%@ include file="head.jsp" %>
    <%@ include file="jquery.jsp" %>
    <script type="text/javascript" src="<c:url value="/dwr/util.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/dwr/engine.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/dwr/interface/starService.js"/>"></script>
    <script type="text/javascript" language="javascript">

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
    </script>
</head>
<body class="mainframe bgcolor1">

<h1>
    <fmt:message key="statistics.title"/>
</h1>

<h2>
    <c:forTokens items="lastplayed topplayed otheruser overall users" delims=" " var="cat" varStatus="loopStatus">
        <c:if test="${loopStatus.count > 1}">&nbsp;|&nbsp;</c:if>
        <sub:url var="url" value="statistics.view">
            <sub:param name="listType" value="${cat}"/>
        </sub:url>
        <c:choose>
            <c:when test="${model.listType eq cat}">
                <span class="headerSelected"><fmt:message key="statistics.${cat}.title"/></span>
            </c:when>
            <c:otherwise>
                <a href="${url}"><fmt:message key="statistics.${cat}.title"/></a>
            </c:otherwise>
        </c:choose>
    </c:forTokens>
</h2>

<c:choose>
	<c:when test="${model.listType eq 'lastplayed'}">
	<!-- lastplayed -->
	</c:when>
</c:choose>
<c:choose>
	<c:when test="${model.listType eq 'topplayed'}">
	<!-- topplayed -->
	</c:when>
</c:choose>
<c:choose>
	<c:when test="${model.listType eq 'otheruser'}">
	<!-- otheruser -->
	</c:when>
</c:choose>
<c:choose>
	<c:when test="${model.listType eq 'overall'}">
	<!-- overall -->
	</c:when>
</c:choose>

<c:choose>
	<c:when test="${model.listType eq 'users'}">
	<!-- user Stats -->
	<br>
			<table>
			<tr>
				<th><fmt:message key="home.chart.total"/></th>
				<th><fmt:message key="home.chart.stream"/></th>
			</tr>
			<tr>
				<td><img src="<c:url value="/userChart.view"><c:param name="type" value="total"/></c:url>" alt=""></td>
				<td><img src="<c:url value="/userChart.view"><c:param name="type" value="stream"/></c:url>" alt=""></td>
			</tr>
			<tr>
				<th><fmt:message key="home.chart.download"/></th>
				<th><fmt:message key="home.chart.upload"/></th>
			</tr>
			<tr>
				<td><img src="<c:url value="/userChart.view"><c:param name="type" value="download"/></c:url>" alt=""></td>
				<td><img src="<c:url value="/userChart.view"><c:param name="type" value="upload"/></c:url>" alt=""></td>
			</tr>
	</table>
	</c:when>
        <c:otherwise>
			<c:if test="${not empty model.songs}">
				<h2><fmt:message key="search.hits.songs"/></h2>
				<table style="border-collapse:collapse">
					<c:forEach items="${model.songs}" var="song" varStatus="loopStatus">

						<sub:url value="/main.view" var="mainUrl">
							<sub:param name="path" value="${song.parentPath}"/>
						</sub:url>

						<tr>
							<c:import url="playAddDownload.jsp">
								<c:param name="id" value="${song.id}"/>
								<c:param name="playEnabled" value="${model.user.streamRole and not model.partyModeEnabled}"/>
								<c:param name="addEnabled" value="${model.user.streamRole and (not model.partyModeEnabled or not song.directory)}"/>
								<c:param name="downloadEnabled" value="${model.user.downloadRole and not model.partyModeEnabled}"/>
								<c:param name="starEnabled" value="true"/>
								<c:param name="starred" value="${not empty song.starredDate}"/>
								<c:param name="video" value="${song.video and model.player.web}"/>
								<c:param name="asTable" value="true"/>
							</c:import>

							<td ${loopStatus.count % 2 == 1 ? "class='bgcolor2'" : ""} style="padding-left:0.25em;padding-right:1.25em">
								<str:truncateNicely upper="45">${song.title}</str:truncateNicely>
							</td>

							<td ${loopStatus.count % 2 == 1 ? "class='bgcolor2'" : ""} style="padding-right:1.25em">
								<a href="${mainUrl}"><span class="detail">${song.albumName}</span></a>
							</td>

							<td ${loopStatus.count % 2 == 1 ? "class='bgcolor2'" : ""} style="padding-right:1.50em">
								<span class="detail">${song.artist}</span>
							</td>
							<c:choose>
								<c:when test="${model.listType eq 'topplayed'}">
									<td ${loopStatus.count % 2 == 1 ? "class='bgcolor2'" : ""} style="padding-right:1.50em">
										<span class="detailcolor">(${song.playCount}x)</span>
									</td>
								</c:when>
							</c:choose>
							<c:choose>
								<c:when test="${model.listType eq 'overall'}">
									<td ${loopStatus.count % 2 == 1 ? "class='bgcolor2'" : ""} style="padding-right:1.50em">
										<span class="detailcolor">(${song.playCount}x)</span>
									</td>
								</c:when>
							</c:choose>				
							<td ${loopStatus.count % 2 == 1 ? "class='bgcolor2'" : ""} style="padding-right:0.25em">
								<span class="detail">${fn:substring(song.lastPlayed, 0, 16)}</span>
							</td>
							</tr>
							
					</c:forEach>
				</table>
				<table>
					<tr style="padding-top:2.5em">
					</tr>
					<tr>
						<sub:url value="statistics.view" var="previousUrl">
							<sub:param name="listOffset" value="${model.listOffset - model.listSize}"/>
							<sub:param name="listType" value="${model.listType}"/>
							</sub:url>
						<sub:url value="statistics.view" var="nextUrl">
							<sub:param name="listOffset" value="${model.listOffset + model.listSize}"/>
							<sub:param name="listType" value="${model.listType}"/>
							</sub:url>

						<td style="padding-right:1.5em"><div class="back"><a href="${previousUrl}"><fmt:message key="common.previous"/></a></div></td>
						<td style="padding-right:1.5em"><fmt:message key="statistics.title"><fmt:param value="${model.listOffset + 1}"/><fmt:param value="${model.listOffset + model.listSize}"/></fmt:message></td>
						<td><div class="forwardright"><a href="${nextUrl}"><fmt:message key="common.next"/></a></div></td>				
						
					</tr>
				</table>
			</c:if>
</c:otherwise>	
</c:choose>

</body></html>