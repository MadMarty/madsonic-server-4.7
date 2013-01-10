<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html><head>
    <%@ include file="head.jsp" %>
    <script type="text/javascript" src="<c:url value="/script/scripts.js"/>"></script>
</head>
<body class="mainframe bgcolor1">

<c:choose>
    <c:when test="${empty model.buildDate}">
        <fmt:message key="common.unknown" var="buildDateString"/>
    </c:when>
    <c:otherwise>
        <fmt:formatDate value="${model.buildDate}" dateStyle="long" var="buildDateString"/>
    </c:otherwise>
</c:choose>

<c:choose>
    <c:when test="${empty model.localVersion}">
        <fmt:message key="common.unknown" var="versionString"/>
    </c:when>
    <c:otherwise>
        <c:set var="versionString" value="${model.localVersion} (build ${model.buildNumber})"/>
    </c:otherwise>
</c:choose>

<h1>
    <img src="<spring:theme code="helpImage"/>" alt="">
    <fmt:message key="help.title"><fmt:param value="${model.brand}"/></fmt:message>
</h1>

<c:if test="${model.newVersionAvailable}">
    <p class="warning"><fmt:message key="help.upgrade"><fmt:param value="${model.brand}"/><fmt:param value="${model.latestVersion}"/></fmt:message></p>
</c:if>

<table width="75%" class="ruleTable indent">
    <tr><td class="ruleTableHeader"><fmt:message key="help.version.title"/></td><td class="ruleTableCell">${versionString} &ndash; ${buildDateString}</td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.server.title"/></td><td class="ruleTableCell">${model.serverInfo} (<sub:formatBytes bytes="${model.usedMemory}"/> / <sub:formatBytes bytes="${model.totalMemory}"/>)</td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.license.title"/></td><td class="ruleTableCell">
        <a href="http://www.gnu.org/copyleft/gpl.html" target="_blank"><img style="float:right;margin-left: 10px" alt="GPL 3.0" src="<c:url value="/icons/gpl.png"/>"></a>
        <fmt:message key="help.license.text"><fmt:param value="${model.brand}"/></fmt:message></td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.contact.title"/></td><td class="ruleTableCell"><fmt:message key="help.contact.text"><fmt:param value="${model.brand}"/></fmt:message></td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.homepage.title"/></td><td class="ruleTableCell"><a target="_blank" href="http://www.subsonic.org/">subsonic.org</a><img style="float:right;margin-left: 10px" alt="Subsonic" src="<c:url value="/icons/subsonic_banner.png"/>"></td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.forum.title"/></td><td class="ruleTableCell"><a target="_blank" href="http://forum.subsonic.org/">forum.subsonic.org</a><img style="float:right;margin-left: 10px" alt="Subsonic" src="<c:url value="/icons/subsonic_banner.png"/>"></td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.subsonic_forum.title"/></td><td class="ruleTableCell"><a target="_blank" href="http://forum.subsonic.org/forum/viewforum.php?f=15">forum.subsonic.org/forum/viewforum.php</a><img style="float:right;margin-left: 10px" alt="Subsonic" src="<c:url value="/icons/subsonic_banner.png"/>"></td></tr>

<!--<tr><td class="ruleTableHeader"><fmt:message key="help.madsonic_contact.title"/></td><td class="ruleTableCell"><a target="_blank" href="http://forum.subsonic.org/forum/memberlist.php?mode=viewprofile&u=8974">forum.subsonic.org/forum/memberlist.php</a><img style="float:right;margin-left: 10px" alt="Subsonic" src="<c:url value="/icons/subsonic_banner.png"/>"></td></tr> -->
    <tr><td class="ruleTableHeader"><fmt:message key="help.madsonic_homepage.title"/></td><td class="ruleTableCell"><a target="_blank" href="http://www.madsonic.org/">madsonic.org</a><img style="float:right;margin-left: 10px" alt="Madsonic" src="<c:url value="/icons/madsonic_banner.png"/>"></td></tr>
    <tr><td class="ruleTableHeader"><fmt:message key="help.madsonic_forum.title"/></td><td class="ruleTableCell"><a target="_blank" href="http://forum.madsonic.org/">forum.madsonic.org</a><img style="float:right;margin-left: 10px" alt="Madsonic" src="<c:url value="/icons/madsonic_banner.png"/>"></td></tr>

    <tr><td class="ruleTableHeader">GitHub</td><td class="ruleTableCell"><a target="_blank" href="https://github.com/MadMarty">www.github.com</a><img style="float:right;margin-left: 10px" alt="Github" src="<c:url value="/icons/github.png"/>"></td></tr>
	<tr><td class="ruleTableHeader">Browser</td><td class="ruleTableCell"><a target="_blank" href="http://www.mozilla.org/de/firefox/new/">www.mozzila.org</a> Recommended Browser<img style="float:right;margin-left: 10px" alt="Firefox" src="<c:url value="/icons/firefox_banner.png"/>"> </td></tr>
	<tr><td class="ruleTableHeader">Donate</td><td class="ruleTableCell">
		<table width="50%">
		<tr><td><a href="<c:url value="/madsonic.view"/>"><img src="<spring:theme code="paypalImage"/>" alt=""></a></td>
		<td>Madsonic</td>
		<td><a href="<c:url value="/donate.view"/>"><img src="<spring:theme code="paypalImage"/>" alt=""></a></td>
		<td>Subsonic</td>
		</tr></table>
		</td></tr>
	</table>
</body></html>