//amd module

define(['jquery', 'jquery-plugin-interface'], function($, Plugin){

    var myPlugin = new Plugin({

        name : 'danPlugin',

        defaults : {
            'bgcolor' : 'red'
        },

        initialize : function(opts) {
            this.defaults.bgcolor = opts.bgcolor || this.defaults.bgcolor;
        },

        methods : {

            public : {
                changeBg : function() {
                    this.methods.private.changeBg(this.$el);
                }
            },

            private : {
                changeBg : function($el) {
                    $el.css('background-color', this.defaults.bgcolor);
                }
            }

        }

    });

    myPlugin.create($);

    return myPlugin;

});