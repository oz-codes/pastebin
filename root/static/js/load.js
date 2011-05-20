Ext.Loader.setConfig({enabled: true});
Ext.Loader.setPath('Ext.hg', '/static/js/hg');

Ext.require([
    'Ext.form.*',
    'Ext.tab.*',
    'Ext.data.*',
    'Ext.grid.*',
    'Ext.direct.*',
    'Ext.hg.CloseTab'
]);

Ext.onReady( function() {
    rev = null;
    l = null
    hasCmp = false;
    bw = Ext.getBody().getViewSize().width
    bh = Ext.getBody().getViewSize().height
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
        ]
    });


    Ext.define('LanguageList', {
        extend: 'Ext.data.Model',
        fields: [
	    "language", "name"
        ]
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


    login = Ext.create("Ext.form.Panel",{
	id: "loginTab",
	title: "Log in",
	items: [{
                xtype: 'fieldset',
                title: 'Log in',
                defaults: {
			width: bw*0.70,
                },
                items: [{
                        fieldLabel: "Username",
			xtype: "textfield",
                        emptyText: "Username...",
                        name: "username",
                        id: 'username'
                }, {
                        fieldLabel: "Password",
			xtype: "textfield",
			inputType: "password",
                        name: 'password',
                        id: 'password'
                }, {
			html: "Click <a href='#' class='register' id='register'>here</a> to register.",
			listeners: {
				afterrender: {
					fn: function() {
						Ext.get("register").on("mousedown",function() {
							   login.disable();
							   register =Ext.create("Ext.form.Panel", {
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
									width: bw*0.72,
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
									width: bw,
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
											Auth.in({username: username, password: pass});
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
		width: bw,
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
					newPaste.enable();
					tabs.setActiveTab(Ext.getCmp("newPaste"));
					/*tabs.add(logout);
					tabs.remove(login,true);
					tabs.refresh();*/
                                }
                        });
                }
        }]
    });
    logout = Ext.create("Ext.panel.Panel",{
        id: "logoutTab",
	disabled: true,
        title: "Log out",
        buttons: [{
                text: "Log out",
		width: bw,
		height: 32,
                handler: function() {
                        Auth.out(function(j) {
                                if(j.error) {
                                        Ext.Msg.alert("Error",j.error);
                                } else {
                                        Ext.Msg.alert("Notice",j.msg);
					login.enable()
					logout.disable();
					newPaste.disable();
					tabs.setActiveTab(Ext.getCmp("newPaste"));
				/*	tabs.add(login);
                                        tabs.remove('logoutTab',true);*/
                                }
                        });
                }
        }]
    });


    newPaste = Ext.create("Ext.form.Panel",{
	id: "newPaste",
	title: "New Paste",
	//height: bw * 0.52,
	waitMsgTarget: true,
	fieldDefaults: {
	},
	items: [{
		xtype: 'fieldset',
		id: "newPasteForm",
		title: 'New Paste',
		defaultType: 'textfield',
		defaults: {
			width: bw*0.52, 
		},
		items: [{
			fieldLabel: "Title",
			emptyText: "Title",
			name: "title",
			id: 'title',
			validator: function(v) {
				if(v.length == 0) {
					return "You can't submit an empty title.";
				} else { return true; }
			}
		}, {
			fieldLabel: "Post",
			xtype: 'textareafield',
			name: 'post',
			id: 'post',
			height: bh*0.3,
			validator: function(v) {
				if(v.length == 0) {
					return "You can't submit empty content.";
				} else { return true; }
			}
		}, {
			fieldLabel: 'Language',
			name: 'lang',
			xtype: 'combobox',
			store: languages,
			forceSelection: true,
			matchFieldWidth: true,
			mode: 'local',
			minChars: 1,
			triggerAction: 'all',
			queryParam: 'query',
			id: 'lang',
			paramsAsHash: true,
			typeAhead: false,
			valueNotFoundText: "That language wasn't found.",
			forceSelection: true,
			valueField: "language",
			displayField: "language",
			emptyText: "Select a language."
		}]
	}],
	buttons: [{
		text: "Submit",
		handler: function() {
			var values = Ext.getCmp("newPaste").getForm().getValues();
			var title = values.title;
			var post = values.post;
			var lang = values.lang;
			lang = lang.replace(/\s*$/,"");
			post = post.replace(/\s*$/,"");
			title = title.replace(/\s*$/,"");
			if(title.length == 0) {
				Ext.Msg.alert("Notice", "You can't submit with an empty title.");
				return false;
			} 
			if(post.length == 0) {
				Ext.Msg.alert("Notice", "Please provide some content for your submission.");
				return false;
			}
			Paste.create({title: title, post: post, lang: lang}, function(j) {
				if(j.error) {
					Ext.Msg.alert("Error",j.error);
				} else {
					Ext.Msg.alert("Notice",j.msg);
					pastes.load();
					pastes.filterBy(function(rec) {
						return true;
					});
					Ext.getCmp("newPaste").getForm().reset();
				}
			});
		}
	}]
	})
    function generateList() { 
				
	list =  Ext.create("Ext.grid.Panel", {
	title: "Saved Pastes",
	id: "pasteList",
	closable: false,
	height: bh*0.5,
	width: bw*0.25,
	store: pastes,
	columns: [
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
				icon: "/static/icons/script_code.png",
				tooltip: "Fork",
				id: "forkIcon",
				handler: function(grid, rowIndex, colIndex) {
					if(hasCmp) { return; }
					hasCmp = true;
					rec = pastes.getAt(rowIndex);
					height=tabs.getHeight();
					    var fork = Ext.create("Ext.form.Panel",{
						closable: true,
						id: "auxPanel",
						title: "Fork "+rec.get("title"),
						height: bh*0.5,
						waitMsgTarget: true,       
						style: { opacity: 0 },
						fieldDefaults: {
						},
						items: [{
							xtype: 'fieldset',
							id: "auxPanelForm",
							title: 'Fork '+rec.get("title").replace(/\w*$/,""),
							defaultType: 'textfield',
							defaults: {
								width: bw*0.72,
							},
							items: [{
								fieldLabel: "Title",
								emptyText: "Title",
								name: "ftitle",
								id: 'ftitle',
								value: "Fork of "+rec.get("title")
							}, {
								fieldLabel: "Post",
								xtype: 'textareafield',
								name: 'fpost',
								id: 'fpost',
								height: bh*0.3,
								value: rec.get("content")
							}, {
								fieldLabel: 'Language',
								name: 'flang',
								xtype: 'displayfield',
								id: 'flang',
								value: rec.get("lang")
							}, {
								xtype: "button",
								text: "Submit",
                                                        handler: function() {
                                                                var values = fork.getForm().getValues();
                                                                var title = values.ftitle;
                                                                var post = values.fpost;
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
                                                                                Ext.getCmp("auxPanel").animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                opacity: 0
                                                                                        }
                                                                                });
                                                                        }
                                                                });
                                                        }
                                                }]
						}],
						listeners: {
							afterrender: {
								fn: function() {
									Ext.getCmp("auxPanel").animate({
										duration: 1000,
										to: {
											opacity: 1
										}
									})
								}
							},
							beforedestroy: {
								fn: function() {
										Ext.getCmp("auxPanel").animate({
											duration: 1000,
											to: {
												opacity: 0
											},
											listeners: {
												afteranimate: {
													fn: function() {
														hasCmp = false;
														Ext.getCmp('auxPanel').getForm().reset();
													}
												}
											}
                                                                                })
										return false;
								}
							}
						}
					})
					misc.add(fork);
					
				}
			}, {
                                icon: "/static/icons/script_code_red.png",
                                tooltip: "New revision",
				id: "revIcon",
				getClass: function(v, m, rec, r, c, s) {
				},
                                handler: function(grid, rowIndex, colIndex) {
					if(hasCmp) { return; }
					hasCmp = true;
                                        rec = pastes.getAt(rowIndex);
                                        height=tabs.getHeight();
                                        Ext.core.DomHelper.insertAfter("ext",{tag: "div", id: "rev"});
                                            var rev = Ext.create("Ext.form.Panel",{
                                                closable: true,
                                                id: "auxPanel",
						height: bh*0.5,
                                                title: "New revision of "+rec.get("title"),
                                                waitMsgTarget: true,
                                                style: { opacity: 0 },
                                                fieldDefaults: {
                                                },
                                                items: [{
                                                        xtype: 'fieldset',
                                                        title: 'New revision of '+rec.get("title").replace(/\w*$/,""),
                                                        defaultType: 'textfield',
                                                        defaults: {
								width: bw*0.72,
                                                        },
                                                        items: [{
                                                                fieldLabel: "Title",
                                                                name: "title",
                                                                id: 'rtitle',
								xtype: "displayfield",
                                                                value: rec.get("title")
                                                        }, {
                                                                fieldLabel: "Post",
                                                                xtype: 'textareafield',
                                                                name: 'rpost',
                                                                id: 'rpost',
                                                                height: bh*0.3,
                                                                value: rec.get("content")
                                                        }, {
                                                                fieldLabel: 'Language',
                                                                name: 'rlang',
                                                                xtype: 'displayfield',
                                                                id: 'rlang',
                                                                value: rec.get("lang")
                                                        }, {
								xtype: "button",
								text: "Submit",
								handler: function() {   
                                                                var values = rev.getForm().getValues();
                                                                var title = rec.get("title")                  
                                                                var post = values.rpost;
                                                                var lang = rec.get("lang")
                                                                lang = lang.replace(/\s*$/,"");
                                                                post = post.replace(/\s*$/,"");
                                                                Paste.createRev({title: title, post: post, lang: lang, oldId: rec.get("id")}, function(j) {
                                                                        if(j.error) {   
                                                                                Ext.Msg.alert("Error",j.error);
                                                                        } else {
                                                                                Ext.Msg.alert("Notice",j.msg);
                                                                                pastes.load();
                                                                                Ext.getCmp("auxPanel").animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                opacity: 0
                                                                                        }
                                                                                });
                                                                        }
                                                                });
                                                        }
						}],
						}],
                                                listeners: {
                                                        afterrender: {
                                                                fn: function() {
                                                                        Ext.getCmp("auxPanel").animate({
                                                                                duration: 1000,
                                                                                to: {
                                                                                        opacity: 1
                                                                                }
                                                                        })
                                                                }
                                                        },
                                                        beforedestroy: {
                                                                fn: function() {
                                                                                Ext.getCmp("auxPanel").animate({
                                                                                        duration: 1000,
                                                                                        to: {
                                                                                                opacity: 0
                                                                                        },
											listeners: {
                                                                                                afteranimate: {
                                                                                                        fn: function() {
														hasCmp = false;
                                                                                                        }
                                                                                                }
                                                                                        }
                                                                                })
                                                                                return false;
                                                                }
                                                        }
                                                }
                                        })
					misc.add(rev);

                                }
			}]
		}
		],
		listeners: {
			itemcontextmenu: {
				fn: function(view,rec,item,index,event) {
				console.info(event);
				event.stopEvent();
				Paste.canDelete({pid : rec.get("id")}, function(r) {
					console.info(r);
					var candel;
					if(r.error || r.candel == 0) {
						candel = true 
					} else {
						candel = false
					}	
					mnu = new Ext.menu.Menu({
						items: [{
							disabled: candel,
							id: "delete-"+rec.get("id"),
							icon: "/static/icons/delete_note.gif",
							text: "Delete "+rec.get("title")
						}],
						listeners: {
							click: {
								fn: function(menu,item,e) {
									if(item.disabled) { return false; }
									Paste.delete({pid: rec.get("id")}, function(r) {
										if(r.error) {
											Ext.Msg.alert("Error",r.error);
										} else {
											Ext.Msg.alert("Notification",r.msg);
											pastes.load();
										}
									});
								}
							}
						}
					});
					x = event.browserEvent.x-10;
					y = event.browserEvent.y-10;
					mnu.showAt(x,y);
					})
				}
			}
		}
    });
    list.on("cellclick", function (g, r, c, e) {
	if(c == 5) { return; }
  	if(i.id == "list-action") {
		return;
	}
	Paste.hasRevision({id : e.data.id} , function(r) {
		if(r.answer > 0) {
			revDialog(e.data)
		} else {
			addPaste(e.data.id);
		}
	})
   }); 
    return list;
    }
    list = generateList();
			
    function closeTab(cmp, e) {
    }
    tabs = Ext.create("Ext.tab.Panel", {
		region: "center",
		id: "tabWidget",
		resizeTabs: true,
		height: bh*0.5,
		enableTabScroll: true,
		defaults: {
			autoScroll : true
		},
		items: [
			Ext.getCmp("newPaste"),
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
							newPaste.disable();
							logout.disable();
							login.enable();
							tabs.setActiveTab(login);
						}
					})
				return true;
				}
			}
		}
    });
    misc = Ext.create("Ext.container.Container", {
	region: "south",
	height: bh*0.5,
    })		
    listPanel = Ext.create("Ext.container.Container", {
	region: "west"
    });
    listPanel.add(list);
    vue = Ext.create('Ext.container.Viewport', {
    layout: 'border',
    renderTo: 'ext',
    height: bh,
    items: [ 
	listPanel,
	tabs,
	misc
     ]
});
	
   tabs.on("click",function() {
		pastes.load();
	})
    // tab generation code
    index = 0;
    function addTab(tab) {
		tabs.add(tab).show();
    }
    function addPaste (paste) {
	id = paste;
	if(Ext.getCmp("paste-"+id)) { return false; }
	Paste.getPaste(id,function(e) {
		if(e.error) {
			Ext.Msg.alert("Error",e.error);
		} else {
			revision = e.revision;
			content = e.content;
			title = e.title;
			lang = e.lang;
			title = title + " ("+lang+")";
			title += (revision!=null)?" (rev "+revision+")":"";
			tab = Ext.create("Ext.panel.Panel",{
				id: "paste-"+id,
				closable: true,
				title: title,
				html: "Link to this: http://hg.fr.am:3002/#"+id+"<br /><br />"+content,
				height: Ext.getBody().getViewSize().height,
				listeners: {
					beforeactivate: {
						fn: function(me) {
						}
					}
				}
			});
			tabs.add(tab).show();
			tab.tab.el.dom.onmousedown = function(ev) {
				if(ev.which == 2) {
					tabs.remove("paste-"+id);
				}
			};
				
		}
	})
    }
			rendered = false;
			rev = false;
    			function revDialog(data) {
					var revs = new Ext.data.Store({
					      model: "PasteList",	
					      proxy: {
						type: "direct",
						directFn: Paste.getRevisions,
						extraParams: {
						    id: data.id
						},
						paramsAsHash: true
					      }
					});
					revs.load()
					id = data.id
                                        function createRevDiag() {
						var rg = null;
						rg = Ext.create("Ext.grid.Panel",{
						region: "west",
                                                id: "revPanel",
						closable: true,
						height: bh*0.5,
                                                title: "Revision list for "+data.title,
                                                style: { opacity: 0 },
                                                store: revs,
						columns: [
						    //new Ext.grid.RowNumberer({width: 31}),
						    {
						      dataIndex: "title",
						      dtext: "revision",
						      flex: 1
						} , {
						      dataIndex: "created_on",
						      text: "Created",
						      flex: 1
						}, {
						      dataIndex: "lang",
						      text: "Language",
						      flex: 1
						 }, {
						      dataIndex: "user_id",
						      text: "Posted by",
						      flex: 1
						 }],
                                                listeners: {
								cellclick: {
								fn: function(g,r,c,e) {
									addPaste(e.data.id)
										rg.destroy();
                                                               }
							},
                                                        afterrender: {
                                                                fn: function() {
									  list.animate({
										duration: 250,
										to: { opacity: 0 },
										listeners: {
											afteranimate: {
												fn: function() {
													listPanel.remove(list);
													listPanel.add(rg);
													a = rg.animate({
														duration: 250,
														to: {
															opacity: 5
														},
														listeners: { 
															beforeanimate: {
																fn: function() {
																}
															},
															afteranimate: { 
																fn: function() { 
																} 
															} 
														}
													})
												}
											}
										}
									})
								}
                                                        },
                                                        beforedestroy: {
                                                                fn: function() {
										if(rev) { return false; } 
                                                                                rg.animate({
                                                                                        duration: 250,
                                                                                        to: {
                                                                                                opacity: 0
                                                                                        },
											listeners: {
                                                                                                afteranimate: {
													fn: function() {
														rev = true;
														list = generateList();
														listPanel.remove(rg);
														listPanel.add(list);
														list.animate({ duration: 250, to: { opacity: 1 }, listeners: { afteranimate: { fn: function() {  } } } });
														rev = false;
                                                                                                        }
                                                                                                }
                                                                                        }
                                                                                })
									return false;
                                                                }
                                                        }
                                        }
					})
					return rg;
				}
				listPanel.add(createRevDiag());


			}
});
