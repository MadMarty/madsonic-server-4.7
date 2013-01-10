<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<html><head>
    <%@ include file="head.jsp" %>
    <script type="text/javascript" src="<c:url value="/script/scripts.js"/>"></script>
</head>
<body class="mainframe bgcolor1">

<h1>
    <img src="<spring:theme code="helpImage"/>" alt="">
    <fmt:message key="log.title"><fmt:param value="${model.brand}"/></fmt:message>
</h1>

<c:if test="${model.user.adminRole}">
    
<h2><img src="<spring:theme code="logImage"/>" alt="">&nbsp;<fmt:message key="help.log"/></h2>

<table style="border-collapse:collapse; white-space:nowrap; border-spacing:1px;" cellpadding="1" class="detailmini">
    <c:forEach items="${model.logEntries}" var="entry">
        <tr> 
            <td>[<fmt:formatDate value="${entry.date}" dateStyle="short" timeStyle="long" type="both"/>]</td>
            <td class="bgcolor2">${entry.level}</td><td>${entry.category}</td><td>${entry.message}</td>
        </tr>
    </c:forEach>
</table>

<p><fmt:message key="log.logfile"><fmt:param value="${model.logFile}"/></fmt:message> </p>

<div class="forward"><a href="log.view?"><fmt:message key="common.refresh"/></a></div>

</c:if>
</body></html>