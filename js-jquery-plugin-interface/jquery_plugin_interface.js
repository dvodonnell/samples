(function(window, factory){

    var nameSpace = 'Plugin',
        jQuery = window.jQuery || false;

    //this factory pattern expanded by DVO to ES6 from github.com/umdjs/blob/master/amdWeb.js

    if (typeof define === 'function' && define.amd) {
        define(factory);
    } else if (typeof exports === 'object') {
        module.exports = factory(jQuery);
    } else {
        window[nameSpace] = factory(jQuery);
    }

})(window, function(jQuery){

    var Plugin = function(definition) {

        this.definition = definition;

    };

    Plugin.prototype = {

        setJQuery : function (jQuery) {

            //jquery instance setter

            this.$ = jQuery;
            return (typeof jQuery === 'function');

        },

        definitionIsValid : function(definition) {

            //definition must be named and have an initializer

            return (
                typeof definition.name === 'string' &&
                typeof definition.initialize === 'function' &&
                typeof definition.methods == 'object'
            );

        },

        create : function(jQueryOverride) {

            //build the plugin and attach to jQuery

            var jQueryAvailable = this.setJQuery((typeof jQueryOverride !== 'undefined') ? jQueryOverride : jQuery);

            var readyToGo = (
                jQueryAvailable &&
                typeof this.definition == 'object' &&
                this.definitionIsValid(this.definition)
            );

            if (readyToGo) {

                //at last, we assign this plugin to jQuery
                this.$.fn[this.definition.name] = this.build();

            }

            return (readyToGo && typeof this.$.fn[this.definition.name] === 'function');

        },

        build : function() {

            //SCOPE: the plugin instance

            var definition = this.definition,
                self = this;

            //this is what will be called by $(...).myPlugin();

            var plugin = function(method) {

                //SCOPE: jquery selector
                var $els = this,
                    numEls = this.length,
                    args = [],            //get any additional arguments passed
                    returnResult = this,
                    stackedResults = [],
                    methodCall = false;

                //determine what plugin method we should be calling

                if (
                    typeof method === 'string' &&
                    typeof definition.methods.public === 'object' &&
                    typeof definition.methods.public[method] === 'function'
                ) {

                    //we've established that a valid public method was called
                    methodCall = definition.methods.public[method];
                    args = Array.prototype.slice.call(arguments, 1);

                } else if (typeof method === 'object' || typeof method === 'undefined') {

                    //no specific method was called, assume initialization
                    methodCall = definition.initialize;
                    args = arguments;

                }

                if (methodCall) {

                    //loop through the selector-matched DOM elements

                    $els.each(function() {

                        //SCOPE: jquery element
                        var $el = $(this);

                        //run the function by passing in a scope-modified version of the definition
                        var result = methodCall.apply(self.mapCopy($el, $els), args);

                        if (typeof result !== 'undefined') {
                            stackedResults.push(result);
                        }

                    });

                    //it's possible the called method returned something; return it or return an array if multiple
                    //elements were found

                    if (stackedResults.length > 1) {
                        returnResult = stackedResults;
                    } else if (stackedResults.length == 1) {
                        returnResult = stackedResults[0];
                    }

                }

                return returnResult;

            };

            return plugin;

        },

        mapCopy : function ($el, $els) {

            //create a mapped version of the definition (plugin) to serve as the scope during execution of its methods

            var definition = this.definition,
                self = this;

            var innerInterface = {
                defaults : definition.defaults,
                $el : $el,
                $els : $els,
                methods : {
                    private : {}
                }
            };

            if (typeof definition.methods.private === 'object') {

                //we only map the private methods; the public methods should not be callable within the plugin

                self.$.each(definition.methods.private, function(privateKey, privateMethod){
                    innerInterface.methods.private[privateKey] = function() {
                        return privateMethod.apply(innerInterface, arguments);
                    };
                });

            }

            return innerInterface;

        }

    };

    return Plugin;

});