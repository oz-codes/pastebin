Ext.Loader.setConfig({enabled: true});
Ext.Loader.setPath('Ext.hg', '/static/js/hg');

Ext.require([
    'Ext.form.*',
    'Ext.tab.*',
    'Ext.direct.*',
    'Ext.data.*',
    'Ext.grid.*',
    'Ext.direct.*',
    'Ext.hg.CloseTab'
]);

Ext.onReady( function() {
    bh = Ext.getBody().getViewSize().height
    bw = Ext.getBody().getViewSize().width
    function generateCtx(store) {
    return function ctx(view,rec,item,index,event) {
                                event.stopEvent();                                                              
                                Paste.canDelete({pid : rec.get("id")}, function(r) {                            
                                        var candel;                                                                             
                                        if(r.error || r.candel == 0) {                                                          
                                                candel = true                                                           
                                        } else {                                                                        
                                                candel = false                                                                  
                                        }                                                                                       
                                        if(Ext.getCmp("delete")) {                                                      
                                                Ext.getCmp("delete").destroy();                                 
                                        }                                                               
                                        mnu = new Ext.menu.Menu({                               
                                                items: [{                               
                                                        disabled: candel,       
                                                        id: "delete",   
                                                        icon: "/static/icons/delete_note.gif",
                                                        text: "Delete "+rec.get("title")
                                                }, {
							id: "reset",
							icon: "/static/icons/page_refresh.png",
							text: "Refresh list"
						}],     
                                                listeners: {    
                                                        click: {                
                                                                fn: function(menu,item,e) {
									if(item.id == "delete") {
										if(item.disabled) { return false; }
										Paste.delete({pid: rec.get("id")}, function(r) {
											if(r.error) {   
												Ext.Msg.alert("Error",r.error);
											} else {
												Ext.Msg.alert("Notification",r.msg);
												store.load();
											}                               
										});                                     
									} else if(item.id == "reset") {
										pastes.load();
									}
                                                                }                                               
                                                        }                                                       
                                                }                                                               
                                        });                                                                     
                                        x = event.getPageX()-10;                                        
					console.log("revs: "+revs);
                                        y = event.getPageY()-10;                                
                                        mnu.showAt(x,y);                                
                                        })
			}
	}
    rev = null;
    l = null
    hasCmp = false;
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
	    "id", "title","created_on","updated_on","lang","user_id","revision","content","hasrev","revs","revnum","ind"
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
											Auth.in({username: username, password: pass},function(j) {
												if(j.error) {} else {
													tabs.remove(register)
													login.disable();
													logout.enable();
													newPaste.enable();
													tabs.setActiveTab(newPaste)
												}
											});
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
					Auth.isAdmin(function(r) {
						if(r.answer == 1) {
							addAdminTab();
						}
					})
				}
					/*tabs.add(logout);
					tabs.remove(login,true);
					tabs.refresh();*/
                                })
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
					tabs.setActiveTab(Ext.getCmp("loginTab"));
					removeAdminTab();
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
				getClass: function(v, m, rec, r, c, s) {
					if(parseInt(rec.get("hasrev")) == 1) { return "hidden"; }
				},
				handler: function(grid, rowIndex, colIndex) {
					Auth.loggedin(function(r) {
						if(r.loggedin != 1) {} else {
						rec = pastes.getAt(rowIndex);
						if(Ext.getCmp("fork"+rec.get("id"))) { return false; }
					    var fork = Ext.create("Ext.form.Panel",{
						closable: true,
						id: "fork"+rec.get("id"),
						title: "Fork "+rec.get("title"),
						items: [{
							xtype: 'fieldset',
							id: "fork"+rec.get("id")+"Form",
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
										tabs.remove(Ext.getCmp("fork"+rec.get("id")));
                                                                        }
                                                                });
                                                        }
                                                }]
						}],
					})
					tabs.add(fork);	
					tabs.setActiveTab(fork);
				}
				})
			}}, {
                                icon: "/static/icons/script_code_red.png",
                                tooltip: "New revision",
				id: "revIcon",
				getClass: function(v, m, rec, r, c, s) {
					if(rec.get("hasrev") == 1) { return "hidden"; }
				},
                                handler: function(grid, rowIndex, colIndex) {
					Auth.loggedin(function(r) {
						if(r.loggedin != 1) {} else {
                                        rec = pastes.getAt(rowIndex);
					if(Ext.getCmp("rev"+rec.get("id"))) { return false; }
                                        Ext.core.DomHelper.insertAfter("ext",{tag: "div", id: "rev"});
                                            var rev = Ext.create("Ext.form.Panel",{
                                                closable: true,
                                                id: "rev"+rec.get("id"),
                                                title: "New revision of "+rec.get("title"),
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
										tabs.remove(rev)
                                                                        }
                                                                });
                                                        }
						}],
						}],
                                        })
					tabs.add(rev);
					tabs.setActiveTab(rev);
				}
				})

                                }
			}]
		}
		],
		listeners: {
			itemcontextmenu: {
				fn: generateCtx(pastes)
			}
		}
    });
    list.on("cellclick", function (g, r, c, e) {
	if(c == 4) { return; }
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
					Auth.loggedin(function(r) {
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
    userPanel = Ext.create("Ext.container.Container", {
	layout: "hbox",
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
	userPanel
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
					function getPaste(id) {
						var tot = pastes.getTotalCount();
						var ret;
						for(i=0;i<tot;i++) {
							rec = pastes.getAt(i);
							idd = parseInt(rec.get("id"));
							if(idd == id) {
								ret = rec;
								break;
							}
						}
						return ret;
					}
					datas = getPaste(data.id);
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
						      dataIndex: "revnum",
						      text: "Revision",
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
						}, {
							xtype: 'actioncolumn',
			id: "list-action",
			items: [{
				icon: "/static/icons/script_code.png",
				tooltip: "Fork",
				id: "forkIcon",
				handler: function(grid, rowIndex, colIndex) {
					Auth.loggedin(function(r) {
						if(r.loggedin != 1) {} else {
						rec = grid.getStore().getAt(rowIndex);
						if(Ext.getCmp("fork"+rec.get("id"))) { return false; }
					    var fork = Ext.create("Ext.form.Panel",{
						closable: true,
						id: "fork"+rec.get("id"),
						title: 'Fork '+rec.get("title")+(rec.get("revnum") != ""?" (revision "+rec.get("revnum")+")":""),
						items: [{
							xtype: 'fieldset',
							id: "fork"+rec.get("id")+"Form",
							title: 'Fork '+rec.get("title")+(rec.get("revnum") != ""?" (revision "+rec.get("revnum")+")":""),
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
                                                                Paste.createFork({title: title, post: post, lang: lang, oldId: data.id}, function(j) {
                                                                        if(j.error) {
                                                                                Ext.Msg.alert("Error",j.error);
                                                                        } else {
                                                                                Ext.Msg.alert("Notice",j.msg);
										pastes.load();
										rg.destroy();	
										tabs.remove(Ext.getCmp("fork"+rec.get("id")));
                                                                        }
                                                                });
                                                        }
                                                }]
						}],
					})
					tabs.add(fork);	
					tabs.setActiveTab(fork);
				}
				})
			}}, {
                                icon: "/static/icons/script_code_red.png",
                                tooltip: "New revision",
				id: "revIcon",
				getClass: function(v, m, rec, r, c, s) {
					ind = rec.get("ind");
					revs = datas.get("revs")
					if(ind != revs) { return "hidden" }
				},
                                handler: function(grid, rowIndex, colIndex) {
					Auth.loggedin(function(r) {
						if(r.loggedin != 1) {} else {
                                        rec = grid.getStore().getAt(rowIndex);
					if(Ext.getCmp("rev"+rec.get("id"))) { return false; }
                                        Ext.core.DomHelper.insertAfter("ext",{tag: "div", id: "rev"});
                                            var rev = Ext.create("Ext.form.Panel",{
                                                closable: true,
                                                id: "rev"+rec.get("id"),
                                                title: "New revision of "+rec.get("title"),
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
                                                                Paste.createRev({title: title, post: post, lang: lang, oldId: data.id}, function(j) {
                                                                        if(j.error) {   
                                                                                Ext.Msg.alert("Error",j.error);
                                                                        } else {
                                                                                Ext.Msg.alert("Notice",j.msg);
										rg.destroy();
										pastes.load();
										grid.getStore().load();
										tabs.remove(rev)
                                                                        }
                                                                });
                                                        }
						}],
						}],
                                        })
					tabs.add(rev);
					tabs.setActiveTab(rev);
				}
				})

                                }
			}]
		}],
                                                listeners: {
								itemcontextmenu: {
									fn: generateCtx(revs)
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
				 rg.on("cellclick", function (g, r, c, e) {
					if(c == 4) { return false; }
					else {
						addPaste(e.data.id)
					}
				   });
					return rg;
				}
				listPanel.add(createRevDiag());


			}

	function addAdminTab() {
		admin = Ext.create("Ext.panel.Panel", {
                                id: "adminpanel",
                                title: "Admin",
                                html: "yeah, we're boring here, soz :(",
                                height: bh*0.5
                        });
			Ext.getCmp("funcpanel").add(admin);
	}
	function removeAdminTab() {
		Ext.getCmp("funcpanel").remove(Ext.getCmp("adminpanel"));
	}
	Auth.isAdmin(function(r) {
		var panel
		var cont = Ext.create("Ext.tab.Panel", {
			id: "funcpanel",
			width: bw*0.5
		})
		if(r.answer == 1) {
			addAdminTab();
		}
			//build user panel
	search  = Ext.create("Ext.form.Panel",{
	id: "searchTab",
	title: "Search",
	height: bh*0.5,
	items: [{
                xtype: 'fieldset',
                title: 'Search',
		defaults: {
			anchor: '100%'
		},
                items: [{
                        fieldLabel: "Search",
			xtype: "textfield",
                        emptyText: "Query...",
                        name: "query",
                        id: 'query',
			validator: function(r) {
				if(r == "") {
					return "Please provide something to search by.";
				} else if(r.length < 3) {
					return "Please provide at least 3 characters to search by.";
				} else { return true; }
			}
                }, {
			xtype: "fieldcontainer",
			fieldLabel: "Case sensitive?",
			defaultType: 'checkboxfield',
			items: [ {
				name: 'cs',
				
				inputValue: true,
				checked: true,
				id: 'cs'
			}]
		}, {
			xtype: 'button',
			text: "Search",
			width: bw*0.5,
			handler: function() {
                        var values = search.getForm().getValues();
			var query = values.query
			if(query == "" || query.length < 3) { return false; }
			var sens = !values.cs;
			var re = new RegExp(query,(sens?"i":""));
			pastes.filterBy(function(rec) {
				title = rec.get("title");
				body = rec.get("content");
				if(body.match(re) || title.match("re")) {
					return true;
				} else {
					return false;
				}
                        })
		}
	}, {
		xtype: 'button',
		text: 'Reset paste list.',
		handler: function() {
			pastes.load();
			search.getForm().reset();
		}
	}]
	}]
    });
			notify = Ext.create("Ext.panel.Panel", {
				id: "notifications",
				tpl: "<div class='msg'>{msg}</div>",
				tplWriteMode: 'append',
				autoScroll: true,
				title: "Notifications",
				height: bh*0.5,
				width: bw*0.5
			})
			/*oldnotify = Ext.create("Ext.panel.Panel", {
				id: "oldnotifications",
				tpl: "<div class='msg'>{msg}</div>",
				tplWriteMode: 'append',
				html: "<em>under construction</i>",
				autoScroll: true,
				title: "Old Notifications",
				height: bh*0.5,
				width: bw*0.5
			})*/
		cont.add(search);
		    poll = new Ext.direct.PollingProvider({
				type:'polling',
				url: '/notify',
				listeners: {
					data: {
						fn: function(provider, event) {
							if(event.nothing) { return false; }
							for(var ix in event.data) {
								ent = event.data[ix];
								
								notify.update({ msg: "<em>Message from the system: </em>"+ent.msg })
								/*oldnotify.update({ msg: "<em>Message from the system: </em>"+ent.msg })*/
								notify.body.scroll("b",100000,true);
							}
						}
					}
				}
		    });
		notz = Ext.create("Ext.tab.Panel",{
			items: [
				notify,
			]
		})
		Ext.direct.Manager.addProvider(poll);
		userPanel.add(cont);
		cont.setActiveTab(search);
		userPanel.add(notz);
	})
});
