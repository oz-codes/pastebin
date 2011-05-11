Ext.Loader.setConfig({enabled: true});
Ext.Loader.setPath('Ext.ux', '/static/js/extjs/examples/ux')

Ext.require([
    'Ext.form.*',
    'Ext.tab.*',
    'Ext.data.*',
    'Ext.grid.*',
    'Ext.direct.*',
    'Ext.ux.TabCloseMenu'

]);
Ext.onReady( function() {

    Ext.state.Manager.setProvider(Ext.create('Ext.state.CookieProvider'));

    Ext.define('PasteList', {
        extend: 'Ext.data.Model',
        fields: [
	    "id", "title","created_on","updated_on","lang"
        ],
	proxy: {
		type: "direct",
		directFn: Paste.pastes,
		paramsAsHash: true
	}
    });


    Ext.define('LanguageList', {
        extend: 'Ext.data.Model',
        fields: [
	    "language", "name"
        ],
	proxy: {
		type: "direct",
		directFn: Paste.languages,
		paramsAsHash: true
	}
    });


    languages = new Ext.data.Store({ 
	model: "LanguageList",
	autoLoad: true,
	proxy: {
		type: "direct",
		directFn: Paste.languages,
		paramsAsHash: true
	}
    });	

    pastes = new Ext.data.Store({
        model: "PasteList",
        autoLoad: true,
        proxy: {
                type: "direct",
                directFn: Paste.pastes,
                paramsAsHash: true
        }
    });


  
    login = new Ext.form.Panel({
	id: "loginTab",
	title: "Log in",
	items: [{
                xtype: 'fieldset',
                title: 'Log in',
                defaultType: 'textfield',
                defaults: {
                        width: 1200,
                },
                items: [{
                        fieldLabel: "Username",
                        emptyText: "Username...",
                        name: "username",
                        id: 'username',
                }, {
                        fieldLabel: "Password",
			inputType: "password",
                        name: 'password',
                        id: 'password',
                }]
        }],
        buttons: [{
                text: "Log in",
                handler: function() {
                        var values = login.getForm().getValues();
                        var username = values.username;
                        var password = values.password;
                        Auth.in({username: username, password: password}, function(j) {
                                if(j.error) {
                                        Ext.Msg.alert("Error",j.error);
                                } else {
                                        Ext.Msg.alert("Notice",j.msg);
					console.info(Ext.getCmp("tabWidget"));
					tabs.tabBar.disableTab(logout);
					tabs.tabBar.activate(login)
					/*tabs.add(logout);
					tabs.remove(login,true);
					tabs.refresh();*/
                                }
                        });
                }
        }],
    });
    logout = new Ext.form.Panel({
        id: "logoutTab",
	disabled: true,
        title: "Log out",
        items: [{
                xtype: 'fieldset',
                title: 'Log out',
                defaultType: 'textfield',
                defaults: {
                        width: 1200,
                },
        }],
        buttons: [{
                text: "Submit",
                handler: function() {
                        Auth.out(function(j) {
                                if(j.error) {
                                        Ext.Msg.alert("Error",j.error);
                                } else {
                                        Ext.Msg.alert("Notice",j.msg);
					login.disable()
					logout.enable();
				/*	tabs.add(login);
                                        tabs.remove('logoutTab',true);*/
                                }
                        });
                }
        }],
    });


    form = new Ext.form.Panel({
	id: "newPaste",
	title: "New Paste",
	bodyPadding: 5,
	waitMsgTarget: true,
		paramsAsHash: true,
	api: {
		submit: Paste.doStuff
	},
	fieldDefaults: {
	},
	items: [{
		xtype: 'fieldset',
		title: 'New Paste',
		defaultType: 'textfield',
		defaults: {
			width: 1200, 
		},
		items: [{
			fieldLabel: "Title",
			emptyText: "Title",
			name: "title",
			id: 'title',
		}, {
			fieldLabel: "Post",
			xtype: 'textareafield',
			name: 'post',
			id: 'post',
			grow: true,
			growMin: 300,
			growMax: 900
		}, {
			fieldLabel: 'Language',
			name: 'lang',
			xtype: 'combobox',
			store: languages,
			id: 'lang',
			typeAhead: true,
			typeAheadDelay: 1,
			forceSelection: true,
			valueField: "language",
			displayField: "language",
			emptyText: "Select a language."
		}]
	}],
	buttons: [{
		text: "Submit",
		handler: function() {
			var values = form.getForm().getValues();
			var title = values.title;
			var post = values.post;
			var lang = values.lang;
			alert("language: "+lang);
			Paste.create({title: title, post: post, lang: lang}, function(j) {
				if(j.error) {
					Ext.Msg.alert("Error",j.error);
				} else {
					Ext.Msg.alert("Notice",j.msg);
					pastes.load();
					form.getForm().reset();
				}
			});
		}
	}],
	})
    list = Ext.create("Ext.grid.Panel", {
	title: "Saved Pastes",
	id: "pasteList",
	closable: false,
	bodyPadding: 5,
	store: pastes,
	columns: [
		new Ext.grid.RowNumberer({width: 31}),
		{
			dataIndex: "title",
			text: "Title",
			flex: 1
		} , {
			dataIndex: "created_on",
			text: "Created",
			flex: 1
		}, {
			dataIndex: "lang",
			text: "Language"
		}
	],
	handler: function(grid,ri,ci) { 
	}
});
			
    tabs = Ext.create("Ext.tab.Panel", {
		stateful: true,
		stateId: "stateTab",
		id: "tabWidget",
		renderTo: 'ext',
		resizeTabs: true,
		enableTabScroll: true,
		defaults: {
			autoScroll : true,
		},
		items: [
			form,
			list,
			login,
			logout
		],
		plugins: Ext.create('Ext.ux.TabCloseMenu', {
            extraItemsTail: [
                '-',
                {
                    text: 'Closable',
                }
            ],
        })
    });
	
	
    list.on("itemclick", function (t, rec, i, index,e) {
	addPaste(rec.get("id"));
   });
   tabs.on("click",function() {
		pastes.load();
	})
		
    // tab generation code
    index = 0;
    function addPaste (paste) {
        ++index;
	id = paste;
	Paste.getPaste(id,function(e) {
		if(e.error) {
			Ext.Msg.alert("Error",e.error);
		} else {
			content = e.content;
			title = e.title;
			lang = e.lang;
			tabs.add({
			    title: title + " ("+lang+")",
			    html: content,
			    closable: true, 
			}).show();
		}
	})
    }
});
