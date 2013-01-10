<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1" %>

<html><head>
    <%@ include file="head.jsp" %>
    <%@ include file="jquery.jsp" %>
</head>
<body class="mainframe bgcolor1">
<script type="text/javascript" src="<c:url value="/script/wz_tooltip.js"/>"></script>
<script type="text/javascript" src="<c:url value="/script/tip_balloon.js"/>"></script>

<c:import url="settingsHeader.jsp">
    <c:param name="cat" value="access"/>
    <c:param name="toast" value="${model.toast}"/>
</c:import>

<form method="post" action="accessSettings.view">
<table class="indent">
    <tr>
        <th><fmt:message key="accessSettings.name"/></th>
		    <c:forEach items="${model.musicFolders}" var="musicFolders">
				<th style="padding-left:1em; width:80px;">${musicFolders.name}</th>
			</c:forEach>
	</tr>

    <c:forEach items="${model.accessToken}" var="accessToken">
        <tr>
			<td>${accessToken.name}</td>
			
			<c:forEach items="${accessToken.accessRights}" var="accessRights">
				<!--<td align="center" style="padding-left:1em">${accessRights.enabled}</td>!-->

				<c:if test="${accessRights.enabled eq 'true'}">
				<td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${accessToken.name}${accessRights.musicfolder_id}]" checked class="checkbox"/></td>
				</c:if>

				<c:if test="${accessRights.enabled ne 'true'}">
				<td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${accessToken.name}${accessRights.musicfolder_id}]" class="checkbox"/></td>
				</c:if>
				

			</c:forEach>
			
			</tr>
    </c:forEach>

	
				<!--		
			<td>${accessToken.accessRights[0].isEnabled}</td>	

				<c:forEach items="${accessToken}" var="xxx" varStatus="status">
			
				<td>${accessRight.count}</td>
				<td>${accessRight.musicfolder_id}</td>
			</c:forEach>


				<td><input style="font-family:monospace" type="text" name="name[${accessToken.id}]" size="15" value="${accessToken.id}"/></td>
            <td><input style="font-family:monospace" type="text" name="name[${accessToken.name}]" size="15" value="${accessToken.name}"/></td>

		
			<td>${accessToken.id}</td>
			<td>${accessToken.name}</td>

			<td><input style="font-family:monospace" type="text" name="name[${accessToken.id}]" size="15" value="${accessToken.name}"/></td>
			
			<c:forEach items="${accessToken}" var="AccessRight">
			</c:forEach>
			-->

			<!--

			<td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${AccessRight.isEnabled}]" checked class="checkbox"/></td>


            <td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${accessToken.id+0}]" class="checkbox"/></td>
            <td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${accessToken.id+1}]" class="checkbox"/></td>
            <td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${accessToken.id+2}]" class="checkbox"/></td>
            <td align="center" style="padding-left:1em"><input type="checkbox" name="toggle[${accessToken.id+3}]" class="checkbox"/></td>
			-->

	
	
    <tr>
        <th colspan="6" align="left" style="padding-top:1em"><fmt:message key="accessSettings.add"/></th>
    </tr>
</table>

<p style="padding-top:0.75em">
	<input type="submit" value="<fmt:message key="common.save"/>" style="margin-right:0.3em">
	<input type="button" value="<fmt:message key="common.cancel"/>" onclick="location.href='nowPlaying.view'" style="margin-right:1.3em">
</p>

</form>



<c:if test="${not empty model.error}">
    <p class="warning"><fmt:message key="${model.error}"/></p>
</c:if>
</body></html>