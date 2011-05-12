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
    Ext.QuickTips.init()
    Ext.define('UserList', {
	extend: 'Ext.data.Model',
	fields: [
	   "id", "username", "name", "email", "last_paste"
	]
   });
		
    Ext.define('PasteList', {
        extend: 'Ext.data.Model',
        fields: [
	    "id", "title","created_on","updated_on","lang","user_id","revision","content"
        ],
	proxy: {
		type: "direct",
		directFn: Paste.pastes,
		paramsAsHash: true
	}, 
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
        },
	filters: [
		{
			property: "revision",
			value: 0
		}
	]
    });


    login = new Ext.form.Panel({
	id: "loginTab",
	title: "Log in",
	items: [{
                xtype: 'fieldset',
                title: 'Log in',
                defaults: {
                        width: 1200,
                },
                items: [{
                        fieldLabel: "Username",
			xtype: "textfield",
                        emptyText: "Username...",
                        name: "username",
                        id: 'username',
                }, {
                        fieldLabel: "Password",
			xtype: "textfield",
			inputType: "password",
                        name: 'password',
                        id: 'password',
                }, {
			html: "Click <a href='#' class='register' id='register'>here</a> to register.",
			listeners: {
				afterrender: {
					fn: function() {
						Ext.get("register").on("mousedown",function() {
							   login.disable();
							   register = new Ext.form.Panel( {
								id: "registerTab",
								title: "Register",
								closable: true,
								listeners: {
									beforedestroy: {
										fn: function() {
											login.enable();
											tabs.setActiveTab(login)
										}
									}
								},
								defaults: {
									width: 1800
								},
								items: [{
									xtype: "fieldset",
									title: "Register",
									defaultType: "textfield",
									items: [{
										fieldLabel: "Username",
										allowBlank: false,
										emptyText: "Username...",
										name: "username",
										id: "reg-username",
										validator: function(v) {
											len = v.length;
											if(len < 3) {
												return "Your username must be longer than 3 characters.";
											} else if(len > 12) {
												return "Your username must be shorter than 12 characters."
											} else if (v.match(/[^\w\-\._]/i)) {
												return "Your username can only be made up of alphanumeric characters (a-z, 0-9), and these symbols: . - _";
											} else {
												return true;
											}
										},
									}, {
										fieldLabel: "Email",
										allowBlank: false,
										emptyText: "Email...",
										id: 'reg-email',
										name: 'email',
										validator: Ext.form.field.VTypes.email
									},  {
										fieldLabel: "Password",
										inputType: "password",
										allowBlank: false,
										id: 'reg-password',
										name: "password"
									}, {
										fieldLabel: "Password, again",
										inputType: "password",
										allowBlank: "false",
										name: "password2",
										id: "reg-password2",
										validator: function(v) {
											pass = Ext.getCmp("reg-password");
											val = pass.getValue();
											if(v!=val) {
												return "The passwords must match."
											} else {
												return true;
											}
										}
									}] 
								}], 
								buttons: [{
									text: "Register",
									width: 2100,
									height: 32,
									handler: function() {
										values = register.getForm().getValues();
										var username = values.username
										var email = values.email
										var pass = values.password
										var passconf = values.password2
										Auth.register({
									username: username,
									email: email,
									password: [ pass, passconf ]}, function(r) {
										if(r.error) {
											Ext.Msg.alert("Error",r.error);
										} else {
											Ext.Msg.alert("Notice",r.msg);
											Auth.login({username: username, password: pass});
											tabs.removeTab(register)
										}
									})
								     }
								}]
								}) 
								tabs.add(register).show()
							})
					}
				}
			}
							
		}]
        }],
        buttons: [{
                text: "Log in",
		width: 2100,
		height: 32,
                handler: function() {
                        var values = login.getForm().getValues();
                        var username = values.username;
                        var password = values.password;
                        Auth.in({username: username, password: password}, function(j) {
                                if(j.error) {
                                        Ext.Msg.alert("Error",j.error);
                                } else {
                                        Ext.Msg.alert("Notice",j.msg);
					login.disable();
					logout.enable();
					tabs.setActiveTab(form);
					/*tabs.add(logout);
					tabs.remove(login,true);
					tabs.refresh();*/
                                }
                        });
                }
        }],
    });
    logout = Ext.create("Ext.panel.Panel",{
        id: "logoutTab",
	disabled: true,
        title: "Log out",
        buttons: [{
                text: "Log out",
		width: 2100,
		height: 32,
                handler: function() {
                        Auth.out(function(j) {
                                if(j.error) {
                                        Ext.Msg.alert("Error",j.error);
                                } else {
                                        Ext.Msg.alert("Notice",j.msg);
					login.enable()
					logout.disable();
					tabs.setActiveTab(form);
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
			height: 400
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
			lang = lang.replace(/\s*$/,"");
			post = post.replace(/\s*$/,"");
			title = title.replace(/\s*$/,"");
			Paste.create({title: title, post: post, lang: lang}, function(j) {
				if(j.error) {
					Ext.Msg.alert("Error",j.error);
				} else {
					Ext.Msg.alert("Notice",j.msg);
					pastes.load();
					pastes.filterBy(function(rec) {
						console.info(rec);
						return true;
					});
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
	maxHeight: 780,
	bodyPadding: 5,
	height: Ext.getBody().getViewSize().height,
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
			flex: 1,
		}, {
			dataIndex: "lang",
			text: "Language",
			flex: 1,
		}, {
			dataIndex: "user_id",
			text: "Posted by",
			flex: 1,
		}, {
			xtype: 'actioncolumn',
			id: "list-action",
			items: [{
				icon: "/static/icons/document-new.png",
				tooltip: "Fork",
				id: "forkIcon",
				handler: function(grid, rowIndex, colIndex) {
					rec = pastes.getAt(rowIndex);
					height=tabs.getHeight();
					Ext.core.DomHelper.insertAfter("ext",{tag: "div", id: "fork"});
					tabs.animate({
						duration: 1000,
						to: {
							height: 0
						}
					})
					    var fork = new Ext.form.Panel({
						closable: true,
						id: "forkPanel",
						title: "Fork "+rec.get("title"),
						bodyPadding: 5,
						waitMsgTarget: true,       
						style: { opacity: 0 },
						fieldDefaults: {
						},
						items: [{
							xtype: 'fieldset',
							title: 'Fork '+rec.get("title").replace(/\w*$/,""),
							defaultType: 'textfield',
							defaults: {
								width: 1200,
							},
							items: [{
								fieldLabel: "Title",
								emptyText: "Title",
								name: "title",
								id: 'title',
								value: "Fork of "+rec.get("title")
							}, {
								fieldLabel: "Post",
								xtype: 'textareafield',
								name: 'post',
								id: 'post',
								height: 400,
								value: rec.get("content")
							}, {
								fieldLabel: 'Language',
								name: 'lang',
								xtype: 'displayfield',
								id: 'lang',
								value: rec.get("lang")
							}]
						}],
						buttons: [{
							text: "Submit",
							handler: function() {
								var values = fork.getForm().getValues();
								var title = values.title;
								var post = values.post;
								var lang = rec.get("lang")
								lang = lang.replace(/\s*$/,"");
								post = post.replace(/\s*$/,"");
								Paste.createFork({title: title, post: post, lang: lang, oldId: rec.get("id")}, function(j) {
									if(j.error) {
										Ext.Msg.alert("Error",j.error);
									} else {
										Ext.Msg.alert("Notice",j.msg);
										pastes.load();
										height+=32;
										Ext.getCmp("forkPanel").animate({
											duration: 1000,
											to: {
												opacity: 0
											}
										});
										tabs.animate({
											duration: 1000,
											to: {
												height: height
											}
										})
									}
								});
							}
						}],
						renderTo: "fork",
						listeners: {
							afterrender: {
								fn: function() {
									Ext.getCmp("forkPanel").animate({
										duration: 1000,
										to: {
											opacity: 1
										}
									})
								}
							},
							beforedestroy: {
								fn: function() {
										Ext.getCmp
                                                                                tabs.animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                height: height
                                                                                        },
										})
										Ext.getCmp("forkPanel").animate({
											duration: 1000,
											to: {
												opacity: 0
											},
											listeners: {
												afteranimate: {
													fn: function() {
														Ext.get("fork").remove();
														Ext.getCmp('forkPanel').getForm().reset();
													}
												}
											}
                                                                                })
										return false;
								}
							}
						}
					})
					
				}
			}, {
                                icon: "/static/icons/document-new.png",
                                tooltip: "New revision",
				id: "revIcon",
				getClass: function(v, m, rec, r, c, s) {
				},
                                handler: function(grid, rowIndex, colIndex) {
                                        rec = pastes.getAt(rowIndex);
                                        height=tabs.getHeight();
                                        Ext.core.DomHelper.insertAfter("ext",{tag: "div", id: "rev"});
                                        tabs.animate({
                                                duration: 1000,
                                                to: {
                                                        height: 0
                                                }
                                        })
                                            var rev = new Ext.form.Panel({
                                                closable: true,
                                                id: "revPanel",
                                                title: "New revision of "+rec.get("title"),
                                                bodyPadding: 5,
                                                waitMsgTarget: true,
                                                style: { opacity: 0 },
                                                fieldDefaults: {
                                                },
                                                items: [{
                                                        xtype: 'fieldset',
                                                        title: 'New revision of '+rec.get("title").replace(/\w*$/,""),
                                                        defaultType: 'textfield',
                                                        defaults: {
                                                                width: 1200,
                                                        },
                                                        items: [{
                                                                fieldLabel: "Title",
								
                                                                name: "title",
                                                                id: 'title',
								xtype: "displayfield",
                                                                value: rec.get("title")
                                                        }, {
                                                                fieldLabel: "Post",
                                                                xtype: 'textareafield',
                                                                name: 'post',
                                                                id: 'post',
                                                                height: 400,
                                                                value: rec.get("content")
                                                        }, {
                                                                fieldLabel: 'Language',
                                                                name: 'lang',
                                                                xtype: 'displayfield',
                                                                id: 'lang',
                                                                value: rec.get("lang")
                                                        }]
}],
                                                buttons: [{
                                                        text: "Submit",
                                                        handler: function() {
                                                                var values = rev.getForm().getValues();
								var title = rec.get("title")                     
								var post = values.post;
                                                                var lang = rec.get("lang")
                                                                lang = lang.replace(/\s*$/,"");
                                                                post = post.replace(/\s*$/,"");
                                                                Paste.createRev({title: title, post: post, lang: lang, oldId: rec.get("id")}, function(j) {
                                                                        if(j.error) {
                                                                                Ext.Msg.alert("Error",j.error);
                                                                        } else {
                                                                                Ext.Msg.alert("Notice",j.msg);
                                                                                pastes.load();
                                                                                Ext.getCmp("revPanel").animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                opacity: 0
                                                                                        }
                                                                                });
                                                                                tabs.animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                height: height
                                                                                        }
                                                                                })
                                                                        }
                                                                });
                                                        }
                                                }],
                                                renderTo: "rev",
                                                listeners: {
                                                        afterrender: {
                                                                fn: function() {
                                                                        Ext.getCmp("revPanel").animate({
                                                                                duration: 1000,
                                                                                to: {
                                                                                        opacity: 1
                                                                                }
                                                                        })
                                                                }
                                                        },
                                                        beforedestroy: {
                                                                fn: function() {
                                                                                Ext.getCmp
                                                                                tabs.animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                height: height
                                                                                        },
                                                                                })
                                                                                Ext.getCmp("revPanel").animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                opacity: 0
                                                                                        },

isteners: {
                                                                                                afteranimate: {
                                                                                                        fn: function() {
                                                                                                                Ext.get("rev").remove();
                                                                                                                Ext.getCmp('revPanel').getForm().reset();
                                                                                                        }
                                                                                                }
                                                                                        }
                                                                                })
                                                                                return false;
                                                                }
                                                        }
                                                }
                                        })

                                }
			}]
		}
		],
	handler: function(grid,ri,ci) { 
	}
});
			
    tabs = Ext.create("Ext.tab.Panel", {
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
		listeners: {
			render: {	
				fn: function() { 
					qst = window.location.hash.substr(1);
					opts = qst.split(/&/);
					if(opts.length < 1) { return; }
					for(i = 0; i < opts.length; i++) {
						if(opts[i] == "") { continue; }
						addPaste(opts[i]);
					}
					Auth.loggedin(null,function(r) {
						if(r.loggedin == 1) {
							logout.enable();
							login.disable();
						} else {
							logout.disable();
							login.enable();
						}
					})
				return true;
				}
			}
		},
		plugins: Ext.create('Ext.ux.TabCloseMenu', {
            extraItemsTail: [
                '-',
                {
                    text: 'Closable',
                }
            ],
        })
    });
	
	
    list.on("cellclick", function (g, r, c, e) {
	if(c == 5) { return; }
  	if(i.id == "list-action") {
		return;
	}
	addPaste(e.data.id);
   });
   tabs.on("click",function() {
		pastes.load();
	})
    tabs.on("beforetabchange",function(tp,n,o) {
	if(n == list) {
		pastes.load();
	}
    });
    // tab generation code
    index = 0;
    function addTab(tab) {
		tabs.add(tab).show();
    }
    function addPaste (paste) {
	id = paste;
	
		
	Paste.getPaste(id,function(e) {
		if(e.error) {
			Ext.Msg.alert("Error",e.error);
		} else {
			content = e.content;
			title = e.title;
			lang = e.lang;
			tab = Ext.create("Ext.panel.Panel",{
				id: "paste-"+id,
				closable: true,
				title: title + " ("+lang+")",
				html: "Link to this: http://hg.fr.am:3002/#"+id+"<br /><br />"+content,
				height: Ext.getBody().getViewSize().height
			});

			tabs.add(tab).show()
		}
	})
    }
});
