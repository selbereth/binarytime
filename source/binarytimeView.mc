import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class binarytimeView extends WatchUi.WatchFace {
  // Six rays leave the screen centre and stop at the screen edge. Their end
  // points (offsets from the centre, y down) are the corners of every shape:
  // right, upper right, upper left, left, lower left, lower right. On a round
  // screen the rays are 60 degrees apart (a hexagon on the circle). On any other
  // screen the slanted rays run into the corners and the others into the side
  // midpoints, so a square screen gets a square. Inner shapes are smaller
  // copies of the same shape, which keeps them square too.
  var rayX = new Array<Float>[6];
  var rayY = new Array<Float>[6];
  // Scale of the main shape and of the seconds ring relative to the ray ends.
  // The seconds ring is bigger than the screen on every shape, so its wedges run
  // off the edge with no outline showing (on a round screen the hexagon's flat
  // edges would otherwise fall short of the circle).
  var mainScale = 1.0;
  var secondsScale = 1.2;

  var isAsleep = false;

  function initialize() { WatchFace.initialize(); }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));

    var halfW = dc.getWidth() / 2.0;
    var halfH = dc.getHeight() / 2.0;
    if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
      var r = halfW < halfH ? halfW : halfH;
      var h = r * 0.866;
      rayX = [ r, r / 2, -r / 2, -r, -r / 2, r / 2 ] as Array<Float>;
      rayY = [ 0.0, -h, -h, 0.0, h, h ] as Array<Float>;
      mainScale = 1.0;
      secondsScale = 1.2;
    } else {
      rayX = [ halfW, halfW, -halfW, -halfW, -halfW, halfW ] as Array<Float>;
      rayY = [ 0.0, -halfH, -halfH, 0.0, halfH, halfH ] as Array<Float>;
      mainScale = 0.88;
      secondsScale = 1.2;
    }
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  // Update the view
  function onUpdate(dc as Dc) as Void {
    // Get the current time and format it correc
    var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);

    var isAm = now.hour < 12;
    var minBinary = decToBinary(now.min, 1);
    var nowHour = now.hour;

    if (!System.getDeviceSettings().is24Hour) {
      nowHour = (nowHour - 1) % 12 + 1;
    }
    var hourBinary = decToBinary(nowHour, 2);

    var dayBinary = decToBinary(now.day, 1);
    var monthBinary = decToBinary(now.month, 2);

    var dayOfWeekBinary = [ 0, 0, 0, 0, 0, 0 ] as Array<Number>;
    if (now.day_of_week != 1) {
      dayOfWeekBinary[now.day_of_week - 2] = 2;
    }

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    var palette = [
      Graphics.COLOR_BLACK, getApp().getProperty("FirstColor"),
      getApp().getProperty("SecondColor"), getApp().getProperty("ComboColor")
    ];
    // Seconds only ever use value 1, so only the first two entries matter.
    var secondsPalette =
        [ Graphics.COLOR_BLACK, getApp().getProperty("SecondsColor") ];

    // Seconds are only drawn when awake, since low power mode redraws once a
    // minute. The main shape is drawn over the ring's interior.
    if (!isAsleep) {
      drawShape(dc, secondsScale, decToBinary(now.sec, 1), isAm,
                secondsPalette);
    }
    drawShape(dc, mainScale, addBinaries(minBinary, hourBinary), isAm, palette);
    drawShape(dc, mainScale * 2 / 3, dayOfWeekBinary, isAm, palette);
    drawShape(dc, mainScale / 2, addBinaries(dayBinary, monthBinary), isAm,
              palette);
  }

  function addBinaries(a as Array<Number>, b as Array<Number>)
      as Array<Number> {
    var arr = new Array<Number>[6];
    for (var i = 0; i < a.size(); i++) {
      arr[i] = a[i] + b[i];
    }
    return arr;
  }

  function decToBinary(n, setter) as Array<Number> {
    // array to store binary number
    var binaryNum = [ 0, 0, 0, 0, 0, 0 ] as Array<Number>;

    // counter for binary array
    var i = 0;
    while (n > 0) {
      // storing remainder in binary array
      binaryNum[i] = n % 2;
      n = Math.floor(n / 2);
      i++;
    }

    for (i = 0; i < binaryNum.size(); i++) {
      if (binaryNum[i] == 1) {
        binaryNum[i] = setter;
      }
    }

    return binaryNum;
  }

  function drawShape(dc, scale, arr as Array<Number>, isAM as Boolean,
                     colorCode as Array) as Void {
    var cx = dc.getWidth() / 2;
    var cy = dc.getHeight() / 2;

    var px = new Array<Float>[6];
    var py = new Array<Float>[6];
    for (var i = 0; i < 6; i++) {
      px[i] = cx + rayX[i] * scale;
      py[i] = cy + rayY[i] * scale;
    }

    // Wedge i is the triangle centre, first, second. Bit 0 is the top wedge,
    // then clockwise.
    var first = [ 2, 0, 0, 4, 4, 3 ];
    var second = [ 1, 1, 5, 5, 3, 2 ];
    for (var i = 0; i < 6; i++) {
      var f = first[i];
      var s = second[i];
      dc.setColor(colorCode[arr[i]], Graphics.COLOR_BLACK);
      dc.fillPolygon([ [ cx, cy ], [ px[f], py[f] ], [ px[s], py[s] ] ]);
    }

    if (isAM) {
      dc.setColor(getApp().getProperty("AmColor"), Graphics.COLOR_BLACK);
    } else {
      dc.setColor(getApp().getProperty("PmColor"), Graphics.COLOR_BLACK);
    }
    for (var i = 0; i < 3; i++) {
      dc.drawLine(px[i], py[i], px[i + 3], py[i + 3]);
    }
    for (var i = 0; i < 6; i++) {
      var n = (i + 1) % 6;
      dc.drawLine(px[i], py[i], px[n], py[n]);
    }
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be
  // started here.
  function onExitSleep() as Void {
    isAsleep = false;
    WatchUi.requestUpdate();
  }

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {
    isAsleep = true;
    WatchUi.requestUpdate();
  }
}
