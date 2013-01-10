<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1" %>

<html><head>
    <%@ include file="head.jsp" %>
    <%@ include file="jquery.jsp" %>
</head>
<body class="mainframe bgcolor1">

<c:import url="settingsHeader.jsp">
    <c:param name="cat" value="cleanup"/>
    <c:param name="toast" value="${model.toast}"/>
    <c:param name="done" value="${model.done}"/>
</c:import>

<p class="forward"><a href="cleanupSettings.view?scanNow"><fmt:message key="musicfoldersettings.scannow"/></a></p>

<c:if test="${command.scanning}">
	<p style="width:60%"><b><fmt:message key="musicfoldersettings.nowscanning"/></b></p>
</c:if>
	
<p class="forward"><a href="cleanupSettings.view?FullscanNow">Make Full Rescan</a></p>

<p class="forward"><a href="cleanupSettings.view?resetPlaylists">Reset Playlists</a></p>

<p class="forward"><a href="cleanupSettings.view?resetControl">Reset Access Control</a></p>

<p class="forward"><a href="cleanupSettings.view?expunge"><fmt:message key="musicfoldersettings.expunge"/></a></p>
<p class="detail" style="width:60%;white-space:normal;margin-top:-10px;">
	<fmt:message key="musicfoldersettings.expunge.description"/>
</p>

<c:if test="${not empty model.error}">
    <p class="warning"><fmt:message key="${model.error}"/></p>
</c:if>
</body></html>