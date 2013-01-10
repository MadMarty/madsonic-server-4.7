<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1" %>
<%--@elvariable id="model" type="Map"--%>

<html><head>
    <%@ include file="head.jsp" %>
    <%@ include file="jquery.jsp" %>
</head>
<body class="mainframe bgcolor1">

<c:import url="settingsHeader.jsp">
    <c:param name="cat" value="share"/>
    <c:param name="toast" value="${model.toast}"/>
    <c:param name="restricted" value="${not model.user.adminRole}"/>
</c:import>

<form method="post" action="shareSettings.view">

    <table class="indent" style="border-collapse:collapse;white-space:nowrap">
        <tr>
            <th style="padding-left:1em"><fmt:message key="sharesettings.name"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.owner"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.description"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.expires"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.lastvisited"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.visits"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.files"/></th>
            <th style="padding-left:1em"><fmt:message key="sharesettings.expirein"/></th>
            <th style="padding-left:1em"><fmt:message key="common.delete"/></th>
        </tr>

        <c:forEach items="${model.shareInfos}" var="shareInfo" varStatus="loopStatus">
            <c:set var="share" value="${shareInfo.share}"/>
            <c:choose>
                <c:when test="${loopStatus.count % 2 == 1}">
                    <c:set var="htmlClass" value="class='bgcolor2'"/>
                </c:when>
                <c:otherwise>
                    <c:set var="htmlClass" value=""/>
                </c:otherwise>
            </c:choose>

            <sub:url value="main.view" var="albumUrl">
                <sub:param name="path" value="${shareInfo.dir.path}"/>
            </sub:url>

            <tr>
                <td ${htmlClass} style="padding-left:1em"><a href="${model.shareBaseUrl}${share.name}" target="_blank">${share.name}</a></td>
                <td ${htmlClass} style="padding-left:1em">${share.username}</td>
                <td ${htmlClass} style="padding-left:1em"><input type="text" name="description[${share.id}]" size="40" value="${share.description}"/></td>
                <td ${htmlClass} style="padding-left:1em"><fmt:formatDate value="${share.expires}" type="date" dateStyle="medium"/></td>
                <td ${htmlClass} style="padding-left:1em"><fmt:formatDate value="${share.lastVisited}" type="date" dateStyle="medium"/></td>
                <td ${htmlClass} style="padding-left:1em; text-align:right">${share.visitCount}</td>
                <td ${htmlClass} style="padding-left:1em"><a href="${albumUrl}" title="${shareInfo.dir.name}"><str:truncateNicely upper="30">${fn:escapeXml(shareInfo.dir.name)}</str:truncateNicely></a></td>
                <td ${htmlClass} style="padding-left:1em">
                    <label><input type="radio" name="expireIn[${share.id}]" value="7"><fmt:message key="sharesettings.expirein.week"/></label>
                    <label><input type="radio" name="expireIn[${share.id}]" value="30"><fmt:message key="sharesettings.expirein.month"/></label>
                    <label><input type="radio" name="expireIn[${share.id}]" value="365"><fmt:message key="sharesettings.expirein.year"/></label>
                    <label><input type="radio" name="expireIn[${share.id}]" value="0"><fmt:message key="sharesettings.expirein.never"/></label>
                </td>
                <td ${htmlClass} style="padding-left:1em" align="center" style="padding-left:1em"><input type="checkbox" name="delete[${share.id}]" class="checkbox"/></td>
            </tr>
        </c:forEach>

        <tr>
            <td colspan="4" style="padding-top:1.5em">
                <input type="submit" value="<fmt:message key="common.save"/>" style="margin-right:0.3em">
                <input type="button" value="<fmt:message key="common.cancel"/>" onclick="location.href='nowPlaying.view'">
            </td>
        </tr>

    </table>
</form>

</body></html>