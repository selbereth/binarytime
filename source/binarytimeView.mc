import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Time.Gregorian;

class binarytimeView extends WatchUi.WatchFace {
  function initialize() { WatchFace.initialize(); }

  // Load your resources here
  function onLayout(dc as Dc) as Void { setLayout(Rez.Layouts.WatchFace(dc)); }

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
      nowHour = nowHour % 12;
    }
    var hourBinary = decToBinary(nowHour, 2);

    var dayBinary = decToBinary(now.day, 1);
    var monthBinary = decToBinary(now.month, 2);

    // Call the parent onUpdate function to redraw the layout
    View.onUpdate(dc);

    drawHexagon(dc, dc.getWidth(), addBinaries(minBinary, hourBinary), isAm);
    drawHexagon(dc, dc.getWidth() / 4, addBinaries(dayBinary, monthBinary),
                isAm);
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

  function drawHexagon(dc, radius, arr as Array<Number>, isAM as Boolean)
      as Void {
    var colorCode = [
      Graphics.COLOR_BLACK, getApp().getProperty("FirstColor"),
      getApp().getProperty("SecondColor"), getApp().getProperty("ComboColor")
    ];

    var halfWidth = dc.getWidth() / 2;
    var halfHeight = dc.getHeight() / 2;

    var arm = radius;
    var sqrt3 = (arm * 1.732) / 2;
    var halfArm = arm / 2;
    var a = [ arm + halfWidth, halfHeight ];
    var b = [ halfArm + halfWidth, halfHeight - sqrt3 ];
    var c = [ halfWidth - halfArm, halfHeight - sqrt3 ];
    var d = [ halfWidth - arm, halfHeight ];
    var e = [ halfWidth - halfArm, sqrt3 + halfHeight ];
    var f = [ halfArm + halfWidth, sqrt3 + halfHeight ];
    var p = [ halfWidth, halfHeight ];

    var iPoints0 = [ c, b, p ] as Lang.Array<Lang.Array<Lang.Numeric>>;
    var iPoints1 = [ a, b, p ] as Lang.Array<Lang.Array<Lang.Numeric>>;
    var iPoints2 = [ a, f, p ] as Lang.Array<Lang.Array<Lang.Numeric>>;
    var iPoints3 = [ e, f, p ] as Lang.Array<Lang.Array<Lang.Numeric>>;
    var iPoints4 = [ e, d, p ] as Lang.Array<Lang.Array<Lang.Numeric>>;
    var iPoints5 = [ d, c, p ] as Lang.Array<Lang.Array<Lang.Numeric>>;

    dc.setColor(colorCode[arr[0]], Graphics.COLOR_BLACK);
    dc.fillPolygon(iPoints0);
    dc.setColor(colorCode[arr[1]], Graphics.COLOR_BLACK);
    dc.fillPolygon(iPoints1);
    dc.setColor(colorCode[arr[2]], Graphics.COLOR_BLACK);
    dc.fillPolygon(iPoints2);
    dc.setColor(colorCode[arr[3]], Graphics.COLOR_BLACK);
    dc.fillPolygon(iPoints3);
    dc.setColor(colorCode[arr[4]], Graphics.COLOR_BLACK);
    dc.fillPolygon(iPoints4);
    dc.setColor(colorCode[arr[5]], Graphics.COLOR_BLACK);
    dc.fillPolygon(iPoints5);

    if (isAM) {
      dc.setColor(getApp().getProperty("AmColor"), Graphics.COLOR_BLACK);
    } else {
      dc.setColor(getApp().getProperty("PmColor"), Graphics.COLOR_BLACK);
    }
    dc.drawLine(a[0], a[1], d[0], d[1]);
    dc.drawLine(b[0], b[1], e[0], e[1]);
    dc.drawLine(c[0], c[1], f[0], f[1]);

    dc.drawLine(a[0], a[1], b[0], b[1]);
    dc.drawLine(b[0], b[1], c[0], c[1]);
    dc.drawLine(c[0], c[1], d[0], d[1]);
    dc.drawLine(e[0], e[1], d[0], d[1]);
    dc.drawLine(f[0], f[1], e[0], e[1]);
    dc.drawLine(a[0], a[1], f[0], f[1]);
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be
  // started here.
  function onExitSleep() as Void {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {}
}
