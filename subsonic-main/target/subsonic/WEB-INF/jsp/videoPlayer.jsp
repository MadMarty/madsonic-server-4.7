<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1" %>

<html>
<head>
    <%@ include file="head.jsp" %>

    <sub:url value="videoPlayer.view" var="baseUrl"><sub:param name="id" value="${model.video.id}"/></sub:url>
    <sub:url value="main.view" var="backUrl"><sub:param name="id" value="${model.video.id}"/></sub:url>

    <sub:url value="/stream" var="streamUrl">
        <sub:param name="id" value="${model.video.id}"/>
    </sub:url>
	
	<sub:url value="/stream" var="streamUrlPath">
        <sub:param name="path" value="${model.video.path}"/>
    </sub:url>
	
    <script type="text/javascript" src="<c:url value="/script/swfobject.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/script/prototype.js"/>"></script>
    <script type="text/javascript" src="<c:url value="/script/scripts.js"/>"></script>
    <script type="text/javascript" language="javascript">

        var player;
        var position;
        var maxBitRate = ${model.maxBitRate};
        var timeOffset = ${model.timeOffset};
		var subtitleFontSize = 15;
		var subtitleFontColor = "#FFFFFF";
		var subtitleBackdrop = "false";
		var streamUrlPath = "${streamUrlPath}"; 
		var srtPath = streamUrlPath.substring(0,streamUrlPath.length-6)+'737274';
		
		function CCSettingCCRatio(){
			var ratio = document.getElementById('CCSeetingsRatioCheck').value;
			if(ratio == "on"){
				 document.getElementById('CCSeetingsRatio').style.display = 'inline';
			}
			else{
				document.getElementById('CCSeetingsRatio').style.display = 'none';
			}
		}
		
		
        function init() {
            var flashvars = {
                id:"player1",
                skin:"<c:url value="/flash/newtubedark.zip"/>",
//              plugins:"metaviewer-1",
                screencolor:"000000",
				plugins:"./flash/captions.swf",
				'captions.file':srtPath,
				'captions.back':subtitleBackdrop,
				'captions.offset':timeOffset,
				'captions.fontSize':subtitleFontSize,
				'captions.color':subtitleFontColor,
                controlbar:"over",
                autostart:"false",
                bufferlength:3,
                backcolor:"<spring:theme code="backgroundColor"/>",
                frontcolor:"<spring:theme code="textColor"/>",
                provider:"video",
                "viral.allowmenu": "false",
                "viral.oncomplete": "false",
                "viral.onpause": "false"
            };
            var params = {
                allowfullscreen:"true",
                allowscriptaccess:"always"
            };
            var attributes = {
                id:"player1",
                name:"player1"
            };

            var width = "${model.popout ? '100%' : '600'}";
            var height = "${model.popout ? '85%' : '360'}";
            swfobject.embedSWF("<c:url value="/flash/jw-player-5.10.swf"/>", "placeholder1", width, height, "9.0.0", false, flashvars, params, attributes);
        }

        function playerReady(thePlayer) {
            player = $("player1");
            player.addModelListener("TIME", "timeListener");
			<c:if test="${not (model.trial and model.trialExpired)}">
				play();
			</c:if> }

        function play() {
            var list = new Array();

			flashvars = {
				file:"${streamUrl}&maxBitRate=" + maxBitRate + "&timeOffset=" + timeOffset + "&player=${model.player}",
				duration:${model.duration} - timeOffset,
				provider:"video",
			};

            player.sendEvent("LOAD", flashvars);
            player.sendEvent("PLAY");
        }

        function timeListener(obj) {
            var newPosition = Math.round(obj.position);
            if (newPosition != position) {
                position = newPosition;
                updatePosition();
            }
        }

        function updatePosition() {
			var duration = ${model.duration};
			var sliderpositiontime = duration / 100;
			var pos = getPosition();
			var newsliderposition = pos / sliderpositiontime;
			newsliderposition = newsliderposition.toFixed();
			
			for(var i = 0; i < 100; i++)
			{
				if(i == newsliderposition)
				{
					document.getElementById('slider_test_point_'+i).style.background = "red";
				}
				else
				{
					document.getElementById('slider_test_point_'+i).style.background = "#777777";
				}
			}
						
            $("position").innerHTML = secondsToTime(pos);
        }
		
		function secondsToTime(seconds) {
            var minutes = Math.round(seconds / 60);
            var seconds = seconds % 60;
			seconds = seconds.toFixed();
			
            var result = minutes + ":";
            if (seconds < 10) {
                result += "0";
            }
            result += seconds;
            return result;
		}

        function changeTimeOffset() {
            timeOffset = $("timeOffset").getValue();
			
			redrawPlayer();
        }
		
        function changeTimeOffsetSlider(pointnr) {
            timeOffset = pointnr.toFixed();
			
			redrawPlayer();
        }
		
		function changeSubtitleFontSize() {
			timeOffset = getPosition();
			subtitleFontSize = $("subtitleFontSize").getValue();
			
			redrawPlayer();
		}
		
		function changeSubtitleFontColor() {
			timeOffset = getPosition();
			subtitleFontColor = $("subtitleFontColor").getValue();
			
			redrawPlayer();
		}
		
		function changeSubtitleBackdrop() {
			timeOffset = getPosition();
			subtitleBackdrop = $("subtitleBackdrop").getValue();
			
			redrawPlayer();
		}
		
        function changeBitRate() {
            maxBitRate = $("maxBitRate").getValue();
            timeOffset = getPosition();
			
			redrawPlayer();
        }
		
		function redrawPlayer() {
			player.remove();

			var wrapperelement = document.getElementById("wrapper");
			var placeholder = document.createElement('div');
			placeholder.setAttribute('id','placeholder1');
			wrapperelement.appendChild(placeholder);
            
			init();
		}

        function popout() {
            var url = "${baseUrl}&maxBitRate=" + maxBitRate + "&timeOffset=" + getPosition() + "&popout=true";
            popupSize(url, "video", 600, 400);
            window.location.href = "${backUrl}";
        }

        function popin() {
            window.opener.location.href = "${baseUrl}&maxBitRate=" + maxBitRate + "&timeOffset=" + getPosition();
            window.close();
        }

        function getPosition() {
            return parseInt(timeOffset) + parseInt(position);
        }

    </script>
	<!--AR MOD START-->
	<script type="text/javascript" src="<c:url value="/script/aspectratio/aspectratio.js"/>"></script>
    <script type="text/javascript" language="javascript">
	function ar_init(){
            var flashvars = {
                id:"player1",
                skin:"<c:url value="/flash/newtubedark.zip"/>",
                screencolor:"000000",
				plugins:"./flash/captions.swf",
				'captions.file':srtPath,
				'captions.back':subtitleBackdrop,
				'captions.offset':timeOffset,
				'captions.fontSize':subtitleFontSize,
				'captions.color':subtitleFontColor,
                controlbar:"over",
                autostart:"false",
                bufferlength:3,
                backcolor:"<spring:theme code="backgroundColor"/>",
                frontcolor:"<spring:theme code="textColor"/>",
                provider:"video",
				stretching:"exactfit",
                "viral.allowmenu": "false",
                "viral.oncomplete": "false",
                "viral.onpause": "false"                				
            };
            var params = {
                allowfullscreen:"true",
                allowscriptaccess:"always"
            };
            var attributes = {
                id:"player1",
                name:"player1"
            };

            var width = "${model.popout ? '100%' : '100%'}";
            var height = "${model.popout ? '90%' : '100%'}";
            swfobject.embedSWF("<c:url value="/flash/jw-player-5.10.swf"/>", "placeholder1", width, height, "9.0.0", false, flashvars, params, attributes);
        }
	</script><!--AR MOD END-->
</head>

<body class="mainframe bgcolor1" style="padding-bottom:0.5em" onload="init();">
<c:if test="${not model.popout}">
    <h1>${model.video.title}</h1>
</c:if>

<c:if test="${model.trial}">
    <fmt:formatDate value="${model.trialExpires}" dateStyle="long" var="expiryDate"/>

    <p class="warning" style="padding-top:1em">
        <c:choose>
            <c:when test="${model.trialExpired}">
                <fmt:message key="networksettings.trialexpired"><fmt:param>${expiryDate}</fmt:param></fmt:message>
            </c:when>
            <c:otherwise>
                <fmt:message
                        key="networksettings.trialnotexpired"><fmt:param>${expiryDate}</fmt:param></fmt:message>
            </c:otherwise>
        </c:choose>
    </p>
</c:if>


<div id="wrapper" style="padding-top:1em">
    <div id="placeholder1"><a href="http://www.adobe.com/go/getflashplayer" target="_blank"><fmt:message key="playlist.getflash"/></a></div>
</div>

<div style="padding-top:0.7em;padding-bottom:0.7em">

    <span id="position" style="padding-right:0.5em">0:00</span>
	
	<span style="padding-right:0.2em">Offset</span>
    <select id="timeOffset" onchange="changeTimeOffset();" style="padding-left:0.25em;padding-right:0.25em;margin-right:0.5em">
        <c:forEach items="${model.skipOffsets}" var="skipOffset">
            <c:choose>
                <c:when test="${skipOffset.value - skipOffset.value mod 60 eq model.timeOffset - model.timeOffset mod 60}">
                    <option selected="selected" value="${skipOffset.value}">${skipOffset.key}</option>
                </c:when>
                <c:otherwise>
                    <option value="${skipOffset.value}">${skipOffset.key}</option>
                </c:otherwise>
            </c:choose>
        </c:forEach>
    </select>
	
	<span style="padding-right:0.2em;padding-left:0.5em;">Bitrate:</span>
    <select id="maxBitRate" onchange="changeBitRate();" style="padding-left:0.25em;margin-left:0em;margin-right:0em">
        <c:forEach items="${model.bitRates}" var="bitRate">
            <c:choose>
                <c:when test="${bitRate eq model.maxBitRate}">
                    <option selected="selected" value="${bitRate}">${bitRate} Kbps</option>
                </c:when>
                <c:otherwise>
                    <option value="${bitRate}">${bitRate} Kbps</option>
                </c:otherwise>
            </c:choose>
        </c:forEach>
    </select>
    
    	<!--AR MOD START-->
	<input type="hidden" id="customAspectRatioCheck" value="auto"><image id="customAspectRatioCheckImg" height="17px" width="17px" src="<c:url value="/script/aspectratio/ar_off.png"/>" style="margin-top:-0.3em;padding-left:0.25em;margin-right:0.2em;cursor:pointer;display:inline" alt="change aspect ratio" title="enable manual aspectratio selection" onClick="ar_check()">
	<div id="changeAspectRatio" style="display:inline;visibility:hidden">
	<select id="aspectRatio" onchange="changeAspectRatio();" style="padding-left:0.25em;padding-right:0.25em;margin-right:0.5em">
					<option value="1:1">1:1</option>
					<option value="4:3">4:3</option>
					<option selected="selected"  value="16:9">16:9</option>
					<option value="16:10">16:10</option>
					<option value="14:9">14:9</option>
					<option value="5:4">5:4</option>
					<option value="1.85">1.85</option>
					<option value="2.21">2.21</option>
					<option value="2.35">2.35</option>
					<option value="custom">custom</option>
    </select>
	<div id="customAspectRatio" style="display:none;padding-left:0.25em;padding-right:0.25em;margin-right:0.5em">
		<input type="text" size="3" id="cust_ar_x"></input>:<input type="text" size="3" id="cust_ar_y"></input><input type="button" id="cust_ar_button" onclick="custAspectRatio()" value="ok">
	</div>
	</div>
	<!--AR MOD END-->

	<!--
	
	<input type="hidden" id="CCSeetingsRatioCheck" value="off"><image id="customAspectRatioCheckImg" height="17px" width="17px" src="<c:url value="/script/aspectratio/ar_off.png"/>" style="margin-top:-0.3em;padding-left:0.25em;margin-right:0.2em;cursor:pointer;display:inline" alt="change aspect ratio" title="enable manual aspectratio selection" onClick="CCSettingCCRatio()">
	
	<div id="CCSeetingsRatio" style="display:inline;visibility:visible">

		<span style="padding-right:0.2em;padding-left:0.5em; border-left: 1px solid gray;">Font:</span>
		<select id="subtitleFontSize" onchange="changeSubtitleFontSize();" style="padding-left:0.25em;margin-left:0em;margin-right:0em">
			<option value="10">10</option>
			<option value="11">11</option>
			<option value="12">12</option>
			<option value="13">13</option>
			<option value="14">14</option>
			<option selected="selected" value="15">15</option>
			<option value="16">16</option>
			<option value="17">17</option>
			<option value="18">18</option>
			<option value="19">19</option>
			<option value="20">20</option>
		</select>
		
		<select id="subtitleFontColor" onchange="changeSubtitleFontColor();" style="padding-left:0.25em;margin-left:0em;margin-right:0em">
			<option value="#FFFFFF" selected="selected" style="background: #FFFFFF">White</option>
			<option value="#FFFF00" style="background: #FFFF00">Yellow</option>
			<option value="#00FFFF" style="background: #00FFFF">Cyan</option>
			<option value="#00FF00" style="background: #00FF00">Green</option>
		</select>
		
		<select id="subtitleBackdrop" onchange="changeSubtitleBackdrop();" style="padding-left:0.25em;margin-left:0em;margin-right:0em">
			<option value="false" selected="selected" >Outline</option>
			<option value="true">Backdrop</option>
		</select>
	</div>
	-->
	
</div>
<!--
<div id="slider_test" class="slider" style="height:16px">

</div>&nbsp;
-->	
	<script type="text/javascript">
		
		//custom
		var duration = ${model.duration};
		var sliderTimeframe = duration / 100;
		var sliderPositionTime = 0;
	
		for(var i = 0; i < 100; i++)
		{
			sliderPositionTime = sliderTimeframe * i;
			document.getElementById('slider_test').innerHTML += '<div id="slider_test_point_'+i+'" title="'+secondsToTime(sliderPositionTime)+'" style="cursor:default;width:6px;height:15px;float:left;background:#555555" onClick="changeTimeOffsetSlider('+ sliderPositionTime +')">&nbsp;</div>';
		}
	</script>
	
<div>
<c:choose>
    <c:when test="${model.popout}">
        <div class="back"><a href="javascript:popin();"><fmt:message key="common.back"/></a></div>
    </c:when>
    <c:otherwise>
        <div class="back" style="float:left;padding-right:2em"><a href="${backUrl}"><fmt:message key="common.back"/></a></div>
        <div class="forward" style="float:left;"><a href="javascript:popout();"><fmt:message key="videoPlayer.popout"/></a></div>
    </c:otherwise>
</c:choose>
</div>
</body>
</html>
