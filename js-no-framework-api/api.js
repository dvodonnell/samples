(function(window, factory){

    var nameSpace = 'Api';

    //append depending on our environment

    if (typeof define === 'function' && define.amd) {
        define(factory);
    } else if (typeof exports === 'object') {
        module.exports = factory();
    } else {
        window[nameSpace] = factory();
    }

})(window, function(){

    //Form the data objects

    var Entity = function(attrs) {
        this.attributes = {};
        if (attrs) {
            this.setData(attrs);
        }
    };

    Entity.prototype = {
        setId : function(id) {
            this.id = id;
        },
        setData : function(data) {
            this.attributes = data;
        },
        get : function(attrib) {
            return this.attributes[attrib] || false;
        }
    };

    var User = function(attrs) {
        this.attributes = {};
        if (attrs) {
            this.setData(attrs);
        }
    };

    User.prototype = Entity.prototype;
    User.prototype.constructor = Entity;

    var Collection = function() {
        this.entities = [];
    };

    Collection.prototype = {
        set : function(entities) {
            var self = this;
            var i = entities.length;
            while (i--) {
                var e = new Entity();
                e.setData(entities[i]);
                self.entities.push(e);
            }
        },
        each : function (cb) {
            var i = this.entities.length;
            while (i--) {
                cb(this.entities[i], i);
            }
        }
    };

    //Form the Utilities

    var Utils = {
        Deferred : function() {

        },
        Promise : function(deferred) {
            this.deferred = def;
        },
        Serialize : function(obj, prefix) {
            var str = [];
            for(var p in obj) {
                if (obj.hasOwnProperty(p)) {
                    var k = prefix ? prefix + "[" + p + "]" : p, v = obj[p];
                    str.push(typeof v == "object" ?
                        serialize(v, k) :
                    encodeURIComponent(k) + "=" + encodeURIComponent(v));
                }
            }
            return str.join("&");
        }
    };

    Utils.Promise.prototype = {
        done: function(callback){
            this.deferred.done(callback);
        },
        fail: function(callback){
            this.deferred.fail(callback);
        }
    };

    Utils.Deferred.prototype = {
        execute: function(list, args){
            var i = list.length;
            args = Array.prototype.slice.call(args);
            while(i--){
                list[i].apply(null, args);
            }
        },
        resolve: function(){
            this.execute(this._done, arguments);
        },
        reject: function(){
            this.execute(this._fail, arguments);
        },
        done: function(callback){
            this._done.push(callback);
        },
        fail: function(callback){
            this._fail.push(callback);
        },
        promise : function() {
            return new Utils.Promise(this);
        }
    };

    //define the API actions

    var apiDefinition = {
        actions : {
            find : {
                type : 'get',
                processArguments : function(args) {
                    return {
                        data : args[1],
                        path : 'find/' + args[0]
                    }
                },
                processResponse : function(ret) {
                    var c = new Collection();
                    c.set(ret.data);
                    return c;
                }
            },
            login : {
                type : 'post',
                processArguments : function(args) {
                    return {
                        data : {
                            username : args[0],
                            password : args[1]
                        },
                        path : 'login'
                    }
                }
            },
            logout : {
                type : 'post',
                processArguments : function(){}
            },
            registerUser : {
                type : 'post',
                processArguments : function(args) {
                    return {
                        data : {
                            email : args[0],
                            password : args[1]
                        },
                        path : 'registerUser'
                    };
                },
                processResponse : function(resp) { }
            }
        },
        contentTypes : {
            //...
        }
    };

    /*
    Finally, form the API object
    */

    var api = function(configuration) {
        this.config = configuration || {};
    };

    //assign all actions to the API

    for (var prop in apiDefinition.actions) {

        var action = apiDefinition.actions[prop];

        api.prototype[prop] = (function(actionObj){

            return function() {

                var requestData = actionObj.processArguments(arguments);

                var replacedData = Utils.Serialize(requestData.data || false),
                    isGet = (actionObj.type && actionObj.type == 'get');

                //set up the api request

                var req = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP"),
                    deferred = new Utils.Deferred();

                //assign event listeners for success and fail and have the deferreds react

                req.addEventListener("load", function(ret){
                    var data = JSON.parse(req.responseText);
                    deferred.resolve(actionObj.processResponse(data));
                }, false);

                req.addEventListener("error", function(){
                    deferred.reject();
                }, false);

                req.open(actionObj.type || 'post', this.config.url + '/' + requestData.path + ((isGet) ? '?'+replacedData : ''), true);

                if (!isGet) {
                    req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
                    req.setRequestHeader("Content-length", (replacedData) ? replacedData.length : 0);
                    req.setRequestHeader("Connection", "close");
                }

                //do the API call

                req.send((!isGet) ? replacedData : '');

                return deferred.promise();

            }

        })(action);

    }

    return api;

});