Elm.Native.Primer = Elm.Native.Primer || {};
Elm.Native.Primer.make = function(elm) {
    elm.Native = elm.Native || {};
    elm.Native.Primer = elm.Native.Primer || {};
    if (elm.Native.Primer.values) return elm.Native.Primer.values;

    var NS = Elm.Native.Signal.make(elm);

    return elm.Native.Primer.values = {
        prime: function(sig){
            setTimeout(function(){
                elm.notify(sig.id, sig.value)
            }, 1);

            return sig;
        }
    };
};
