<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html><head>
    <%@ include file="head.jsp" %>

    <script type="text/javascript" language="javascript">
        function deletePlaylist(deleteUrl) {
            if (confirm("<fmt:message key="playlist.load.confirm_delete"/>")) {
                location.href = deleteUrl;
            }
        }
    </script>
</head>
<body class="mainframe bgcolor1">

<h1>
    <c:choose>
        <c:when test="${model.load}">
            <fmt:message key="playlist.load.title"/>
        </c:when>
        <c:otherwise>
            <fmt:message key="playlist.load.appendtitle"/>
        </c:otherwise>
    </c:choose>
</h1>
<c:choose>

    <c:when test="${empty model.playlists}">
        <p class="warning"><fmt:message key="playlist.load.empty"/></p>
    </c:when>
    <c:otherwise>
        <table class="ruleTable indent">
            <c:forEach items="${model.playlists}" var="playlist">
                <sub:url value="loadPlaylistConfirm.view" var="loadUrl"><sub:param name="id" value="${playlist.id}"/></sub:url>
                <sub:url value="appendPlaylistConfirm.view" var="appendUrl">
                    <sub:param name="id" value="${playlist.id}"/>
                    <sub:param name="player" value="${model.player}"/>
                    <sub:param name="dir" value="${model.dir}"/>
                    <c:forEach items="${model.indexes}" var="index">
                        <sub:param name="i" value="${index}"/>
                    </c:forEach>
                </sub:url>
                <sub:url value="deletePlaylist.view" var="deleteUrl"><sub:param name="id" value="${playlist.id}"/></sub:url>
                <sub:url value="download.view" var="downloadUrl"><sub:param name="playlist" value="${playlist.id}"/></sub:url>
                <tr>
                    <td class="ruleTableHeaderPlaylists">${playlist.name}</td>
                    <td class="ruleTableCellPlaylists">
					<Table>
					<tr>
                        <c:choose>
                            <c:when test="${model.load}">
							<td>
                                <div class="forward"><a href="${loadUrl}"><fmt:message key="playlist.load.load"/></a></div>
                                <c:if test="${model.user.downloadRole}">
							</td>
							<td>
                                <div class="forward"><a href="${downloadUrl}"><fmt:message key="common.download"/></a></div>
                                </c:if>
							</td>
                            </c:when>
							<c:otherwise>
							<td>
                                <c:if test="${model.user.playlistRole}">
                                    <div class="forward"><a href="${appendUrl}"><fmt:message key="playlist.load.append"/></a></div>
                                </c:if>
							</td>
                            </c:otherwise>
                        </c:choose>
						</td>
					</tr>
					</table>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </c:otherwise>
</c:choose>

</body></html>