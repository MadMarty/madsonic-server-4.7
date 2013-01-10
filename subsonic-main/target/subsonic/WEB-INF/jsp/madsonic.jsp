<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1" %>
<html>
<head>
    <%@ include file="head.jsp" %>
</head>
<body class="mainframe bgcolor1">

<h1>
    <img src="<spring:theme code="donateImage"/>" alt=""/>
    <fmt:message key="madsonic.title"/>
</h1>
<c:if test="${not empty command.path}">
    <sub:url value="main.view" var="backUrl">
        <sub:param name="path" value="${command.path}"/>
    </sub:url>
    <div class="back"><a href="${backUrl}">
        <fmt:message key="common.back"/>
    </a></div>
    <br/>
</c:if>

<c:url value="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=martin%2ekarel%40hotmail%2ecom&lc=US&item_name=Madsonic%20Mashup%20Mod&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" var="donateUrlFree"/>
<c:url value="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=martin%2ekarel%40hotmail%2ecom&lc=US&item_name=Madsonic%20Mashup%20Mod&amount=5%2e00&currency_code=EUR&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" var="donateUrl05"/>
<c:url value="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=martin%2ekarel%40hotmail%2ecom&lc=US&item_name=Madsonic%20Mashup%20Mod&amount=10%2e00&currency_code=EUR&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" var="donateUrl10"/>
<c:url value="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=martin%2ekarel%40hotmail%2ecom&lc=US&item_name=Madsonic%20Mashup%20Mod&amount=20%2e00&currency_code=EUR&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" var="donateUrl20"/>
<c:url value="https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=martin%2ekarel%40hotmail%2ecom&lc=US&item_name=Madsonic%20Mashup%20Mod&amount=30%2e00&currency_code=EUR&no_note=0&currency_code=EUR&bn=PP%2dDonationsBF%3abtn_donate_SM%2egif%3aNonHostedGuest" var="donateUrl30"/>

<div style="width:50em; max-width:50em">

<fmt:message key="madsonic.textbefore"><fmt:param value="${command.brand}"/></fmt:message>

<table cellpadding="10">
    <tr>
        <td>
            <table>
                <tr>
                    <td><a href="${donateUrlFree}" target="_blank"><img src="<spring:theme code="paypalImage"/>" alt="#"/></a> </td>
                </tr>
                <tr>
                    <td class="detail" style="text-align:center;">free Amount</td>
                </tr>
            </table>
        </td>
        <td>
            <table>
                <tr>
                    <td><a href="${donateUrl05}" target="_blank"><img src="<spring:theme code="paypalImage"/>" alt="#"/></a> </td>
                </tr>
                <tr>
                    <td class="detail" style="text-align:center;"><fmt:message key="madsonic.amount"></fmt:message>&euro;5</td>
                </tr>
            </table>
        </td>
        <td>
            <table>
                <tr>
                    <td><a href="${donateUrl10}" target="_blank"><img src="<spring:theme code="paypalImage"/>" alt="#"/></a> </td>
                </tr>
                <tr>
                    <td class="detail" style="text-align:center;"><fmt:message key="madsonic.amount"></fmt:message>&euro;10</td>
                </tr>
            </table>
        </td>
        <td>
            <table>
                <tr>
                    <td><a href="${donateUrl20}" target="_blank"><img src="<spring:theme code="paypalImage"/>" alt="#"/></a> </td>
                </tr>
                <tr>
                    <td class="detail" style="text-align:center;"><fmt:message key="madsonic.amount"></fmt:message>&euro;20</td>
                </tr>
            </table>
        </td>		
        <td>
            <table>
                <tr>
                    <td><a href="${donateUrl30}" target="_blank"><img src="<spring:theme code="paypalImage"/>" alt="#"/></a> </td>
                </tr>
                <tr>
                    <td class="detail" style="text-align:center;"><fmt:message key="madsonic.amount"></fmt:message>&euro;30</td>
                </tr>
            </table>
        </td>		
	</tr>
</table>

<fmt:message key="madsonic.textafter"/>

</div>
</body>
</html>