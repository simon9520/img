<%@ page contentType="text/html;charset=UTF-8" %>
<%@ include file="/WEB-INF/views/include/taglib.jsp" %>
<html>
<head>
    <title>王湖地图</title>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <!-- 高德地图插件 -->
    <script src="${ctxStatic}/adminlte/js/url.js"></script>
    <script src="http://webapi.amap.com/maps?v=1.4.15&key=6c0f2946691e2761373dd72939035012"></script>
    <link rel="stylesheet" href="${ctxStatic}/gdmap/css/map.css"/>
    <script src="${ctxStatic}/gdmap/js/jquery-1.8.3.min.js"></script>
</head>
<body>
<style>
    a {
        color: #dbd3c5;
    }

    .dataDiv {
        float: left;
        margin-left: 10px;
    }

    .title {
        text-align: center;
        font-size: 17px;
    }
</style>
<!--头部开始-->
<div id="container" style="width:100%;height: 100%">

</div>
</body>

<script type="text/javascript">
    var marker = new Array();
    var windowsArr = new Array();
    var points = [];
    var flag = "${flag}";
    var map = new AMap.Map("container", {
        resizeEnable: true,
        zoom: 14, //地图显示的缩放级别
        zooms: [5, 18],
        mapStyle: 'amap://styles/light', //设置地图的显示样式
        center: [${a}, ${b}]
    });

    //刷新页面点位
    initmap();
    //1分钟初始化一下地图
    window.setInterval(initmap, 30000);


    function getSatation() {
        var stationJSON = [];
        $.ajax({
            url: "${ctx}/overview/getStation",
            type: "post",
            data: {"regionId": flag},
            async: false,
            contenttype: "application/json;chaset=utf-8",
            datatype: "json",
            success: function (result) {
                stationJSON = $.parseJSON(result.arr);
            }
        });
        return stationJSON;
    }

    function initmap() {
        var resStation = getSatation();
        if (resStation.length > 0) {
            clearMap();
            for (var i = 0; i < resStation.length; i++) {
                addmarker(i, resStation[i]);
            }
        } else {
            layer.msg('暂无数据接入', {icon: 0});
        }
    }

    /* 清除地图 */
    function clearMap() {
        map.clearMap();
        windowsArr = [];
        marker = [];
        points.splice(0, points.length);
    }

    /* 添加marker&infowindow  */
    function addmarker(i, d) {
        var lngX = d.lngX;
        var latY = d.latY;
        var isalarm = d.alarm;
        var noData = d.noData;
        if (isalarm) {
            str = "<div class='position park'><i class='alarm'>" + (i + 1) + "</i></div>";
        } else {
            if (noData) {
                str = "<div class='position park'><i class='nodata'>" + (i + 1) + "</i></div>";
            } else {
                if (d.remarks === '巨元') {
                    str = "<div class='position park'><i class='juyuan'>" + (i + 1) + "</i></div>";
                } else {
                    str = "<div class='position park'><i class='jiali'>" + (i + 1) + "</i></div>";
                }
            }
        }

        var markerOption = {
            map: map,
            content: str,
            title: d.name,
            label: {
                content: d.name,
                direction: 'bottom',
                offset: new AMap.Pixel(-10, 50),
            },
            position: new AMap.LngLat(lngX, latY)
        };
        var mar = new AMap.Marker(markerOption);
        marker.push(new AMap.LngLat(lngX, latY));
        var popupDiv = "<div id='detailDiv' style='line-height:28px;color:white;position: relative;'><div class='title'>" + d.name + "</div>";
        if (d.devList.length === 0) {
            d.devList.push({devId: ''});
        }
        for (var i = 0; i < d.devList.length; i++) {
            popupDiv += appendDataDiv(d.heatId, d.devList[i]);
        }
        popupDiv += "</div>";
        for (let devData in d.devList) {
        }
        var infoWindow = new AMap.InfoWindow({
            content: popupDiv,
            size: new AMap.Size(0, 0),
            autoMove: true,
            offset: new AMap.Pixel(0, -25)
        });
        windowsArr.push(infoWindow);

        /*   鼠标移入点位时展示信息框 */
        var MouseOver_CallBack = function (e) {
            infoWindow.open(map, mar.getPosition());
        };
        var MouseOut_CallBack = function (e) {
            infoWindow.close();
        };
        AMap.event.addListener(mar, "click", MouseOver_CallBack);
        // AMap.event.addListener(mar, "mouseover", MouseOver_CallBack);
        // AMap.event.addListener(mar, "mouseout", MouseOut_CallBack);

    }

    function appendDataDiv(heatId, devObj) {
        return "<div class='dataDiv'>" +
            "<div>一次供水温度：" + Number(devObj.A_GT1 || 0).toFixed(2) + "℃</div>" +
            "<div>一次回水温度：" + Number(devObj.A_HT1 || 0).toFixed(2) + "℃</div>" +
            "<div>二次供水温度：" + Number(devObj.A_GT2 || 0).toFixed(2) + "℃</div>" +
            "<div>二次回水温度：" + Number(devObj.A_HT2 || 0).toFixed(2) + "℃</div>" +
            "<div>流量：" + Number(devObj.A_INST_FLOW || 0).toFixed(2) + "m³/h</div>" +
            "<div><a href='dataDetail?regionId=" + flag + "&id=" + heatId + "&devId=" + devObj.devId + "'>查看2.5D图</a></div>" +
            "</div>";
    }

</script>
</html>