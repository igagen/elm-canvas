Elm.Native.Canvas = {};
Elm.Native.Canvas.make = function(elm) {
	elm.Native = elm.Native || {};
	elm.Native.Canvas = elm.Native.Canvas || {};
	if (elm.Native.Canvas.values) {
		return elm.Native.Canvas.values;
	}

	var createNode = Elm.Native.Graphics.Element.make(elm).createNode;
  var newElement = Elm.Native.Graphics.Element.make(elm).newElement;

  var List = Elm.List.make(elm);
  var NativeList = Elm.Native.List.make(elm);
  var toCss = Elm.Native.Color.make(elm).toCss;
  var Task = Elm.Native.Task.make(elm);

  var canvases = {};

  function drawCanvas(model) {
    var c = model.cache.context;

    var commandFns = {
      Clear: function(cmd) { var r = cmd._0; c.clearRect(r.x, r.y, r.w, r.h); },
      FillPath: function(cmd) { drawPath(cmd); c.fill(); },
      StrokePath: function(cmd) { drawPath(cmd); c.stroke(); },
      FillText: function(cmd) { c.fillText(cmd._0, cmd._1, cmd._2); },
      StrokeText: function(cmd) { c.strokeText(cmd._0, cmd._1, cmd._2); },

      DrawImage: function(cmd) { c.drawImage(cmd._2, cmd._0, cmd._1); },

      FillColor: function(cmd) {
        var color = toCss(cmd._0);
        c.fillStyle = toCss(cmd._0);
      },
      StrokeColor: function(cmd) {c.strokeStyle = toCss(cmd._0);},
      FillGrad: function(cmd) { c.fillStyle = gradient(cmd); },
      StrokeGrad: function(cmd) { c.strokeStyle = gradient(cmd); },
      FillPattern: function(cmd) { c.fillStyle = getPattern(cmd); },
      StrokePattern: function(cmd) { c.strokeStyle = getPattern(cmd); },

      LineWidth: function(cmd) { c.lineWidth = cmd._0; },
      LineCapStyle: function(cmd) { c.lineCap = cmd._0.ctor.slice(0, -3).toLowerCase(); },
      LineJoinStyle: function(cmd) { c.lineJoin = cmd._0.ctor.slice(0, -4).toLowerCase(); },
      LineMiterLimit: function(cmd) { c.miterLimit = cmd._0; },

      ShadowBlur: function(cmd) { c.shadowBlur = cmd._0; },
      ShadowColor: function(cmd) { c.shadowColor = toCss(cmd._0); },
      ShadowOffset: function(cmd) { c.shadowOffsetX = cmd._0; c.shadowOffsetY = cmd._1; },

      Translate: function(cmd) { c.translate(cmd._0, cmd._1); },
      Rotate: function(cmd) { c.rotate(cmd._0); },
      Scale: function(cmd) { c.scale(cmd._0, cmd._1); },

      Font: function(cmd) { c.font = cmd._0; },
      Alpha: function(cmd) { c.globalAlpha = cmd._0; },

      Composite: function(cmd) {
        var compositeOp = {
          SourceOver: 'source-over',
          SourceIn: 'source-in',
          SourceOut: 'source-out',
          SourceAtop: 'source-atop',
          DestinationOver: 'destination-over',
          DestinationIn: 'destination-in',
          DestinationOut: 'destination-out',
          DestinationAtop: 'destination-atop',
          Lighter: 'lighter',
          Copy: 'copy',
          Xor: 'xor',
          Multiply: 'multiply',
          Screen: 'screen',
          Overlay: 'overlay',
          Darken: 'darken',
          Lighten: 'lighten',
          ColorDodge: 'color-dodge',
          ColorBurn: 'color-burn',
          HardLight: 'hard-light',
          SoftLight: 'soft-light',
          Difference: 'difference',
          Exclusion: 'exclusion',
          Hue: 'hue',
          Saturation: 'saturation',
          Color: 'color',
          Luminosity: 'luminosity'
        }[cmd._0.ctor];

        c.globalCompositeOperation = compositeOp;
      },

      Context: function(cmd) {
        c.save();
        runCommands(cmd._0);
        c.restore();
      }
    };

    var pathFns = {
      ClosePath: function() { c.closePath(); },
      Rect: function(pathMethod) { var r = pathMethod._0; c.rect(r.x, r.y, r.w, r.h); },
      MoveTo: function(pathMethod) { var p = pathMethod._0; c.moveTo(p.x, p.y); },
      LineTo: function(pathMethod) { var p = pathMethod._0; c.lineTo(p.x, p.y); },
      Arc: function(pathMethod) { var a = pathMethod._0; c.arc(a.x, a.y, a.r, a.startAngle, a.endAngle, a.ccw); },
      ArcTo: function(pathMethod) { var at = pathMethod._0; c.arcTo(at.x1, at.y1, at.x2, at.y2, at.r); }
    };

    function drawPath(pathCmd) {
      var pathMethods = NativeList.toArray(pathCmd._0);
      c.beginPath();

      for (var i = 0; i < pathMethods.length; i++) {
        var pathMethod = pathMethods[i]; var pathFn = pathFns[pathMethod.ctor];
        if (pathFn) { pathFn(pathMethod); }
        else { console.error('Unimplemented path method: ' + pathMethod.ctor); }
      }

      if (pathCmd.ctor == 'Fill') { c.fill(); }
      else if (pathCmd.ctor == 'Stroke') { c.stroke(); }
    }

    function gradient(grad) {
      if (grad._0.ctor == 'Linear') {
        return linearGradient(grad._0);
      }
      else if (grad._0.ctor == 'Radial') {
        return radialGradient(grad._0);
      }
      else {
        throw "Unrecognized gradient type: " + grad._0.ctor;
      }
    }

    function linearGradient(grad) {
      var start = grad._0; var end = grad._1;
      var g = c.createLinearGradient(start._0, start._1, end._0, end._1);

      var stops = NativeList.toArray(grad._2);
      for (var i = 0; i < stops.length; i++) {
        var stop = stops[i];
        g.addColorStop(stop._0, toCss(stop._1));
      }

      return g;
    }

    function radialGradient(grad) {
      var start = grad._0; var end = grad._2;
      var r0 = grad._1; var r1 = grad._3;
      var g = c.createRadialGradient(start._0, start._1, r0, end._0, end._1, r1);

      var stops = NativeList.toArray(grad._4);
      for (var i = 0; i < stops.length; i++) {
        var stop = stops[i];
        g.addColorStop(stop._0, toCss(stop._1));
      }

      return g;
    }

    // Return cached pattern if present, otherwise create it
    function getPattern(cmd) {
      var image = cmd._0._0;
      var repeat = {
        Repeat: 'repeat',
        RepeatX: 'repeat-x',
        RepeatY: 'repeat-y',
        NoRepeat: 'no-repeat'
      }[cmd._0._1.ctor];

      var key = null;
      if (image.src) {
        key = image.src;
      }
      else if (canvases[image]) {
        key = image;
        image = canvases[image];
      }
      else {
        throw("Unknown element type for image: " + image);
      }

      model.cache.patterns = model.cache.patterns || {};
      var patterns = model.cache.patterns;
      patterns[key] = patterns[key] || {};
      patterns[key][repeat] = patterns[key][repeat] || c.createPattern(image, repeat);

      return patterns[key][repeat];
    }

    function runCommands(commands) {
      var cmds = NativeList.toArray(commands);
      for (var i = 0; i < cmds.length; i++) {
        var command = commandFns[cmds[i].ctor];
        if (command) {
          command(cmds[i]);
        }
        else {
          console.error('Unimplemented draw command: ' + cmds[i].ctor);
        }
      }
    }

    runCommands(model.commands);
  }

	function canvas(id, dimensions, commands) {
    var w = dimensions._0;
    var h = dimensions._1;

    function render(model) {
      var div = createNode('div');
      div.style.overflow = 'hidden';
      var canvas = createNode('canvas');
      var context = canvas.getContext('2d');

      model.cache.canvas = canvas;
      model.cache.context = context;

      canvases[model.id] = canvas;

      update(div, model, model);

      return div;
    }

    function update(div, oldModel, newModel) {
      newModel.cache = oldModel.cache;

      var canvas = newModel.cache.canvas;

      canvas.style.width = oldModel.w + 'px';
      canvas.style.height = oldModel.h + 'px';
      canvas.style.display = "block";
      canvas.style.position = "absolute";
      canvas.width = oldModel.w;
      canvas.height = oldModel.h;

      drawCanvas(newModel);

      div.appendChild(canvas);

      return div;
    }

    var elem = {
      ctor: 'Custom',
      type: 'Canvas',
      render: render,
      update: update,
      model: {
        commands: commands,
        cache: {},
        w: w,
        h: h,
        id: id
      }
    };

    return A3(newElement, w, h, elem);
  }

	function loadImage(src) {
		return Task.asyncFunction(function(callback) {
      var img = new Image();

      img.onload = function() {
        return callback(Task.succeed(img));
      };

      img.onerror = function() {
        return callback(Task.fail("Failed to load image: '" + src + "'"));
      };

      img.src = src;
		});
	}

	return elm.Native.Canvas.values = {
		canvas: F3(canvas),
    loadImage: loadImage
	};
};
