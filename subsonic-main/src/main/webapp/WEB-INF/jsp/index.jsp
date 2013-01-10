<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="iso-8859-1"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">

<html><head>
    <%@ include file="head.jsp" %>
    <link rel="alternate" type="application/rss+xml" title="Subsonic Podcast" href="podcast.view?suffix=.rss">
</head>

<frameset rows="82,*,0" border="0" framespacing="0" frameborder="0">
    <frame name="upper" src="top.view?">
    <frameset cols="253,*" border="${model.LeftFrameResizeable ? 1 : 0}" framespacing="0" frameborder="${model.LeftFrameResizeable ? 1 : 0}">
        <frame name="left" src="left.view?" marginwidth="0" marginheight="0">
        <frameset rows="74%,26%" border="${model.PlayQueueResizeable ? 1 : 0}" framespacing="0" frameborder="${model.PlayQueueResizeable ? 1 : 0}">
            <frameset cols="*,${model.showRight ? 220 : 0}" border="0" framespacing="0" frameborder="0">
                <frame name="main" src="home.view?listType=${model.listType}&listRows=${model.listRows}&listColumns=${model.listColumns}" marginwidth="0" marginheight="0">
                <frame name="right" src="right.view?" >
            </frameset>
            <frame name="playQueue" src="playQueue.view?" scrolling="${model.customScrollbar ? 'no' : 'yes'}" >
        </frameset>
    </frameset>
    <frame name="hidden" frameborder="0" noresize="noresize">

</frameset>

</html>