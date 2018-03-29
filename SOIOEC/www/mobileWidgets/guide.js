/*
	@author: leeenx
	@当前文件为Paipai Mobile Modules的必要代码
	@组件文件存放于modules文件中
	@使用组件前必须载入pm.js文件，否则可能会造必须方法丢失（有部分方法可以独立运行，如果touch_drag）
	@常用方法use用于加入插件，并回调
	@halo.use('msgbox'...,function(m){},false/true);
	@注意的是最后一个boolean表示强制等待组件加载完成，如果为false表示不等待，这个时候m会有一个onready方法，用于监听组件加载情况
	@halo.use('msgbox',function(m){m.onready(function(){.....});},false);与halo.use('msgbox',function(){...},true);等价。当然不写默认为true
*/
var halo=function(){
	var version='20140624';//统一时间缀
	//事件统一
	var TOUCH='stop',BEFORE_TOUCH='',TOUCH_X=0,TOUCH_Y=0,OFFSET_X=0,OFFSET_Y=0,vector_x=0,vector_y=0,sense_x=5,sense_y=5/*手指灵敏度*/,min_vector=50/*手势成立最小位移*/,gesture_time=500/*200毫秒内手指完成手势*/,start_time=0,end_time=0,longpress_time=500;
	if('ontouchstart' in document){
		var touchstart='touchstart',touchend='touchend',touchmove='touchmove';
	}else{
		var touchstart='mousedown',touchend='mouseup',touchmove='mousemove';
	}
	document.body.addEventListener(touchstart,
		function(e){
			TOUCH='start',BEFORE_TOUCH='',OFFSET_X=0,OFFSET_Y=0,start_time=new Date().getTime();
			if('touchstart'==touchstart){
				var touchers=e.changedTouches||e.targetTouches,toucher=touchers[0];
				TOUCH_X=toucher.pageX,TOUCH_Y=toucher.pageY;
			}else{
				TOUCH_X=e.clientX,TOUCH_Y=e.clientY;
			}
		},true);
	document.body.addEventListener(touchmove,
		function(e){
			if('start'!=TOUCH&&'move'!=TOUCH)return ;
			var offset_x=0,offset_y=0;
			if('touchstart'==touchstart){
				var touchers=e.changedTouches||e.targetTouches,toucher=touchers[0];
				vector_x=toucher.pageX-TOUCH_X,vector_y=toucher.pageY-TOUCH_Y;
				offset_x=Math.abs(vector_x),offset_y=Math.abs(vector_y);
			}else{
				offset_x=Math.abs(e.clientX-TOUCH_X),offset_y=Math.abs(e.clientY-TOUCH_Y);
			}
			if(offset_x>sense_x||offset_y>sense_y){
				BEFORE_TOUCH=TOUCH,
				TOUCH='move';//手指移动在sense_x,sense_y内都不算move
			}
			OFFSET_X=offset_x,OFFSET_Y=offset_y;
			end_time=new Date().getTime();
		},true);
	document.body.addEventListener(touchend,function(e){BEFORE_TOUCH=TOUCH,TOUCH='stop';},true);
	document.body.addEventListener('touchcancel',function(e){BEFORE_TOUCH=TOUCH,TOUCH='stop';},true);
	var modules={length:0};//已经加载的普通组件
	var needWait=true,//强制加载完成组件后才可以执行use回调
		path='widget/'//默认加载路径
		;
	//创建modules的副本，便于复制
	var _fun=function(){},_fun_=function(){};
	_fun.prototype=modules,_fun_.prototype=new _fun();
	var _modules=new _fun_();
	//以下是私有方法
	var load_module=function(filename,cb){
		var script=document.createElement("script");
		script.onload=function(){
			if(typeof(cb)=='function')cb('success');
		}
		script.onerror=function(){
			//加载出错
			if(typeof(cb)=='function')cb('error');
		}
		script.onabort=function(){
			//加载被停止
			if(typeof(cb)=='function')cb('abort');
		}
		script.type='text/javascript',script.src=path+filename+'.js?v='+version;
		document.head.appendChild(script);
		//document.head.removeChild(script);//触发加载即可，节点立马删除
	}
	//以下是事件绑定与解绑
	var on=function(elem,event,cb,type){
		var pm_cb=evcb.set(elem,event,cb);
		event=_event(event);
		elem.addEventListener(event,pm_cb,type);
	},
	off=function(elem,event,cb,type){
		if(typeof(cb)=='undefined'){
			//如果没有回调传入表示将所有事件函数删除
			evcb.del(elem,event);
		}else{
			var pm_cb=evcb.get(elem,event,cb,'remove_cb');
			event=_event(event);
			elem.removeEventListener(event,pm_cb,type);
		}
	},_event=function(event){
		//统一事件
		if('touchstart'==event)event=touchstart;
		else if('touchmove'==event)event=touchmove;
		else if('touchend'==event)event=touchend;
		else if('hold'==event)event=touchstart;
		else if('forcerelease'==event)event='touchcancel';
		else event=touchend;
		return event;
	},evcb=function(){//事件管理数组
		var ev={},set=function(elem,event,cb){
			var tag=elem.getAttribute('haloEV');
			if(!tag){
				tag='pm_'+new Date().getTime(),elem.setAttribute('haloEV',tag);
			}
			ev[tag]=ev[tag]||{},ev[tag][event]=ev[tag][event]||{pm_cb:[],cb:[]},ev[tag][event].cb.push(cb);
			if(touchmove!=event&&'flick'!=event&&'hold'!=event&&event.indexOf('gesture')=="-1"){
				var pm_cb=cb;
			}else if(touchmove==event){//原生事件需要封装的只有touchmove
				var pm_cb=function(){
					if('move'==TOUCH){
						cb.apply(this,arguments);
					}
				};
			}else if('flick'==event){
				var pm_cb=function(){
					if('start'==BEFORE_TOUCH){
						cb.apply(this,arguments);
					}
				}
			}else if('gesture_left'==event){
				//手势向左
				var pm_cb=function(){
					if(OFFSET_X>=OFFSET_Y&&vector_x<=-1*min_vector&&(end_time-start_time<=gesture_time)){
						cb.apply(this,arguments);
					}
				}
			}else if('gesture_right'==event){
				//手势向右
				var pm_cb=function(){
					if(OFFSET_X>=OFFSET_Y&&vector_x>=min_vector&&(end_time-start_time<=gesture_time)){
						cb.apply(this,arguments);
					}
				}
			}else if('gesture_up'==event){
				//手势向上
				var pm_cb=function(){
					if(OFFSET_Y>=OFFSET_X&&vector_y<=-1*min_vector&&(end_time-start_time<=gesture_time)){
						cb.apply(this,arguments);
					}
				}
			}else if('gesture_down'==event){
				//手势向下
				var pm_cb=function(){
					if(OFFSET_Y>=OFFSET_X&&vector_y>=min_vector&&(end_time-start_time<=gesture_time)){
						cb.apply(this,arguments);
					}
				}
			}else if('release'==event||'forcerelease'==event){
				//touchmove后touchend/touchcancel
				var pm_cb=function(){
					if('start'==BEFORE_TOUCH){
						cb.apply(this,arguments);
					}
				}
			}else if('hold'==event){
				//长按
				var pm_cb=function(){
					var _this=this,_start_time=start_time;
					setTimeout(function(){
						if(_start_time==start_time&&'stop'!=TOUCH){
							cb.apply(_this,arguments);
						}
					},longpress_time)
				}
			}
			ev[tag][event].pm_cb.push(pm_cb);
			return pm_cb;
		},get=function(elem,event,cb,remove){
			var tag=elem.getAttribute('haloEV');
			if(!tag)return ;
			if(ev[tag]&&ev[tag][event]){
				for(var i=0,evs=ev[tag][event],len=evs.cb.length;i<len;++i){
					if(evs.cb[i]==cb){
						var ret=evs.pm_cb[i];
						if(remove){
							delete evs.cb[i],delete evs.pm_cb[i];
						}
						return ret;
					}
				}
				return cb;
			}
		},del=function(elem,event){
			var tag=elem.getAttribute('haloEV'),_event_=_event(event);
			if(!tag)return ;
			if(ev[tag]&&ev[tag][event]){
				for(var i=0,evs=ev[tag][event],len=evs.cb.length;i<len;++i){
					elem.removeEventListener(_event_,evs.pm_cb[i],false);
					elem.removeEventListener(_event_,evs.pm_cb[i],true);
				}
			}
		},_o={set:set,get:get,del:del};
		return _o;
	}();
	//css操作方法
	var webkit=function(){
		//浏览器特有css样式的
		var css3_div=document.createElement("div");
		css3_div.style.cssText='-webkit-transition:all .1s; -moz-transition:all .1s; -o-transition:all .1s; -ms-transition:all .1s; transition:all .1s;';
		if(css3_div.style.webkitTransition){
			return '-webkit-';
		}else if(css3_div.style.mozTransition){
			return '-moz-';
		}else if(css3_div.style.oTransition){
			return '-o-';
		}else if(css3_div.style.msTransition){
			return '-ms-';
		}else{
			return '';
		}
	}();
	var STYLESHEET=function(){
		var styleSheet=function(){
			//创建一个styleSheet,避免跨域问题
			var head = document.getElementsByTagName("head")[0]; 
			var style = document.createElement("style"); 
			style.type="text/css"; 
			head.appendChild(style);
			return document.styleSheets[document.styleSheets.length-1];
		}();
		function addStyleSheet(cssText){/*动态添加css样式*/
			var oCss = styleSheet,cssRules=cssText.split('\r\n');
			var len=!!oCss.cssRules?oCss.cssRules.length:0;//不直接使用oCss.cssRules.length是因为跨域时返回null，所以用len避免错误
			for(var i=0;i<cssRules.length;++i){
				oCss.insertRule(cssRules[i],len++);
			};
			return len;
		}
		return {add:addStyleSheet};
	}();
	var addClass=function(elem,_class){
		var className=elem.className,classReg=new RegExp('(^'+_class+'\\s+)|(\\s+'+_class+'\\s+)|(\\s+'+_class+'$)|(^'+_class+'$)','g');
		if(!className)elem.className=_class;
		else if(classReg.test(className))return;
		else elem.className=className+' '+_class;
	}
	var removeClass=function(elem,_class){
		var className=elem.className,classReg=new RegExp('(^'+_class+'\\s+)|(\\s+'+_class+'\\s+)|(\\s+'+_class+'$)|(^'+_class+'$)','g');
		className=className.replace(classReg,function(k,$1,$2,$3,$4){if($2)return ' ';else return '';});
		elem.className=className;
	}
	var get_transform_value=function(transform,key,index){
		//transform即transform的所有属性,key键名，index_arr按数组索引取value
		key=key.replace(/\-/g,'\\-');
		var index_list=[0];
		if(arguments.length>2){
			for(var i=2;i<arguments.length;++i){
				index_list[i-2]=arguments[i];
			}
		}
		if('none'==transform||''==transform)return null;//没有值，直接中断
		var reg=new RegExp(key+'\\(([^\\)]+)\\)','ig'),key_value=transform.match(reg),value_list=[],ret=[];
		if(key_value&&key_value.length>0){
			key_value=key_value[0];
			value_list=key_value.replace(reg,'$1').split(',');
			for(var i=0;i<index_list.length;++i){
				ret.push(value_list[index_list[i]]);
			}
		}
		if(ret.length==1)ret=ret[0];
		else if(index)ret=ret[index];
		return ret;
	}
	modules.on=on,modules.off=off,modules.removeClass=removeClass,modules.addClass=addClass,modules.stylesheet=STYLESHEET.add,modules.get_transform_value=get_transform_value,modules.webkit=webkit;
	//以下是公用方法
	var config=function(o){
		//配置默认属性
		if(typeof(o.wait)!='undefined'){
			needWait=!!o.wait;
		}
		path=o.path||path;
	}
	var add=function(name,fun,isPublic){
		//组件添加
		if(modules[name]){
			throw('命名冲突！');
		}else{
			if(!isPublic){
				modules[name]=fun;++modules.length;
			}else{//公用组件应该存放于public中

			}
		}
	}
	var usePublic=function(){//载入公用方法 - 此方法只有强制加载后执行
		var arg=arguments,need_load_count=0,loaded_count=0,cb=function(){};
		for(var i=0,len=arg.length;i<len;++i){
			if(typeof(arg[i])=='string'){
				arg[i]='../public/'+arg[i];
			}
		}
		use.apply({isPublic:true},arg);
	}
	var use=function(){//载入用户自己组件方法
		var arg=arguments,need_load_count=0,loaded_count=0,cb=function(){},wait=needWait,isPublic=this.isPublic;
		for(var i=0,len=arg.length;i<len;++i){
			var name=arg[i];
			if(typeof(name)=='string'){
				++need_load_count;
				if(!!modules[name])++loaded_count;//已经加载成功
				else{//需要加载
					(function(name){
						load_module(name,function(ret){
							if('success'){//console.log(name)
								if(!isPublic){
									chkReg(name,function(){
										++loaded_count;//文件加载成功并且将方法注册到modules中去，表示真正完成
									});
								}else{//公共组件不需要chkReg
									++loaded_count;
								}
							}else{
								if(!isPublic){
									++loaded_count;//没有加载完成忽略
								}else{
									throw('public file load fail!');
								}
							}
						});
					}(name));
				}
			}else{
				break;//遇到不是string直接中断
			}
		}
		if(typeof(arg[i])=="function"){
			cb=arg[i];
			//在有回调的情况下判断需不需要强制加载完成执行
			if(typeof(arg[i+1])!='undefined')wait=!!arg[i+1];
		};
		if(!wait){
			//不需要等待组件加载，直接执行
			_modules.onready=function(cb){_modules.ready=typeof(cb)=='function'?cb:function(){}};
			cb(_modules);
		}
		//需要等待加载组件加载完成执行回调
		chkLoad();
		function chkLoad(){
			//检查加载情况
			if(loaded_count==need_load_count){
				//加载完成
				if(wait){
					cb(modules);
				}else{
					_modules.ready(modules);
				} 
			}else{
				setTimeout(chkLoad,500)
			}
		}
		//检查组件加载成功，并且成功注册成
		function chkReg(name,cb){
			if(modules[name]){
				if(typeof(cb)=='function')cb();
			}else{
				setTimeout(function(){chkReg(name,cb);},500)
			}
		}
	}




	var util = function(){
		var getBF = function(){
	        var ua = navigator.userAgent.toLowerCase();
	        var scene = (ua.indexOf('micromessenger')) > -1 ? 'weixin' : ((/qq\/([\d\.]+)*/).test(ua) ? 'qq': 'web');
	        return scene;
	    }
	    var transitionEnd = function() {
	        var el = document.createElement('div')

	        var transEndEventNames = {
	          'WebkitTransition' : 'webkitTransitionEnd',
	          'MozTransition'    : 'transitionend',
	          'OTransition'      : 'oTransitionEnd otransitionend',
	          'transition'       : 'transitionend'
	        }

	        for (var name in transEndEventNames) {
	          if (el.style[name] !== undefined) {
	            return { end: transEndEventNames[name] }
	          }
	        }

	        return false;
	    }

	    var requestAnimationFrame = window.requestAnimationFrame ||
	        window.mozRequestAnimationFrame ||
	        window.webkitRequestAnimationFrame ||
	        window.msRequestAnimationFrame ||
	        window.oRequestAnimationFrame ||
	        function(callback) {return setTimeout(callback, 1000 / 60); };      

	    var cancelAnimationFrame = window.cancelAnimationFrame ||
	        window.mozCancelAnimationFrame ||
	        window.webkitCancelAnimationFrame ||
	        window.msCancelAnimationFrame ||
	        window.oCancelAnimationFrame ||
	        function(callback) {return clearTimeout(callback, 1000 / 60); };

	    
	    
	    

	    var extend = function(){
	    	var args = Array.prototype.slice.call(arguments, 0), attr;
	    	var o = args[0];
	    	var deep = false;
	    	if(typeof args[args.length - 1] == 'boolean'){
	    		deep = args[args.length - 1];
	    		args.pop();
	    	}
	    	for(var i = 1; i < args.length; i++){
	    		for(attr in args[i]) {
	    			if(deep && typeof args[i][attr] == 'object'){
	    				o[attr] = {};
	    				extend(o[attr], args[i][attr], true);
	    			}
	    			else
		            	o[attr] = args[i][attr];
		        }
	    	}	        
	        return o;
	    }

	    var proxy = function(scope, fn){
	        scope = scope || null;
	        return function(){
	            fn.apply(scope, arguments);
	        }
	    }

	    var get = function(url, data, cb){
	    	var _createAjax = function() {
			    var xhr = null;
			    try {
			        //IE系列浏览器
			        xhr = new ActiveXObject("microsoft.xmlhttp");
			    } catch (e1) {
			        try {
			            //非IE浏览器
			            xhr = new XMLHttpRequest();
			        } catch (e2) {
			            window.alert("您的浏览器不支持ajax，请更换！");
			        }
			    }
			    return xhr;
			}
			var pram = '';
			if(typeof data == 'object'){
				for(var name in data){
					pram += '&' + name + '=' + data['name'];
				}
			}
			pram.replace(/^&/, '?');
			var xhr = _createAjax();
			if(!url) return;
			xhr.open('get', url + pram, true);
			xhr.send(null);
			xhr.onreadystatechange = function() {
				if (xhr.readyState == 4 && xhr.status == 200) {
		            cb&&cb();
		        }
			}
	    }

	    var noop = function(){};

		return{
			'noop' : noop,
	        'transitionEnd' : transitionEnd,
	        'RAF' : requestAnimationFrame,
	        'cRAF' : cancelAnimationFrame,
	        'extend' : extend,
	        'proxy' : proxy,
	        'getBF' : getBF,
	        'get' : get,
	        'addClass' : addClass,
	        'removeClass' : removeClass,
	        'addStyle' : add,
	        'getTransform' : get_transform_value
		}
	}();

	var Event = (function(){
        var _EventList = {};

        var bind = function( name, fn, scope){
            if(typeof scope == 'object'){
            	if(!scope['event']){
            		scope['event'] = {};         		
            	}
            	if(!scope['event'][name]){
            		scope['event'][name] = [];
            	}
            	scope['event'][name].push(fn);
            	return;
            }
            if(!_EventList[name]){
                _EventList[name] = [];
            }
            _EventList[name].push(fn);
        }

        var trigger = function(name, scope, args){
            var _list = _EventList[name];
            if(scope['event'] && scope['event'][name]){
            	_list = scope['event'][name];
            }
            if(_list == undefined) return;
            for (var i = 0; i < _list.length; i++) {
                _list[i].call(scope,  args || {});
            };
        }

        return {
            bind:bind,
            trigger:trigger
        }

    })();

    var timer = {
        remainTime: function(y,mm,d,h,min,s){
            var endDate = new Date(y,mm - 1,d,h,min,s).getTime();
            var nowDate = new Date().getTime();
            var _leftTime = endDate - nowDate; 
            if(_leftTime < 0){
                return {
	                'hour' : 0,
	                'min' : 0,
	                'sec' : 0
                }
            }
            var hour = Math.floor(_leftTime/3600000);
            _leftTime = _leftTime%3600000;
            var min = Math.floor(_leftTime/60000);
            _leftTime = _leftTime%60000;
            var sec = Math.floor(_leftTime/1000);
            return {
                'hour' : hour,
                'min' : min,
                'sec' : sec
            }
        }
    }

	Function.prototype.delegate = function(scope){
        var that = this;
        return function(){
            that.apply(scope, arguments);
        };
    };

	return {timer:timer,util:util,Event:Event,add:add,use:use,usePublic:usePublic,config:config,on:on,off:off,removeClass:removeClass,addClass:addClass,stylesheet:STYLESHEET.add,get_transform_value:get_transform_value};
}();

(function(){
	if(halo.shareConfig && halo.shareConfig.shareStatistics){
		halo.use('Statistics');
	}
	document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {

	    WeixinJSBridge.on('menu:share:timeline', function(argv){
	        WeixinJSBridge.invoke('shareTimeline',halo.shareConfig, function() {
	            	if(halo.shareConfig.shareStatistics && halo.Statistics)
	                    halo.Statistics.share();
	        });
	    });

	    WeixinJSBridge.on('menu:share:appmessage', function(argv){
	        WeixinJSBridge.invoke('sendAppMessage',halo.shareConfig, function() {
	            	if(halo.shareConfig.shareStatistics && halo.Statistics)
	                    halo.Statistics.share();
	        })
	    });
	});
})();

(function(exports){
        var images = {};

        var Loader = function(source){
            this._source = [];
            this.fails   = [];
            this._index  = 0;
            this.failed  = 0;
            this.loaded  = 0;
            this.percent = '0%';
            this._init(source);            
            this.total = this._source.length;
            this._load();
        }

        Loader.prototype = {
            _rsuffix: /\.(js|css|mp3)$/,
            _init: function (src) {
                 if (typeof src === 'string') {
                     this._source.push(src);
                 } else if (Array.isArray(src)) {
                     this._source = src;
                 } else
                     throw 'Loader Error: arguments must be String|Array.';
            },
            _get_load_method: function (src) {
                var type = (type = src.match(this._rsuffix)) ? type[1] : 'img';
                return '_' + type;
            },
            _js: function (url, ok) {
                var self = this;
                var script = document.createElement('script');
                script.onload = function () {
                    ok && ok.call(self, true, url);
                };
                script.onerror = function () {
                    ok && ok.call(self, false, url);
                };
                script.type = 'text/javascript';
                script.src = url;
                document.head.appendChild(script);
            },
            _css: function (url, ok) {
                var self = this;
                var link = document.createElement('link');
                link.type = 'text/css';
                link.rel = 'stylesheet';
                link.href = url;
                document.head.appendChild(link);
                ok && ok.call(self, true, url);
            },
            _img: function (url, ok) {
                var self = this;
                var img = new Image();
                img.onload = function () {
                    images[url] = img;
                    ok && ok.call(self, true, url);
                };
                img.onerror = function () {
                    ok && ok.call(self, false, url);
                };
                img.src = url;
            },
            _mp3: function(url, ok){
                
            },
            _load: function () {
                if (this._index == this._source.length)
                    return this._onend();
                var src = this._source[this._index];
                if (!src) return;
                var method = this._get_load_method(src);
                this[method](src, this._loadend);
                this._onloadstart(src);
            },
            _loadend: function (done, src) {
                if (done)
                    ++this.loaded;
                else {
                    ++this.failed;
                    this.fails.push(src);
                }
                ++this._index;
                this.percent = Math.ceil(this._index / this.total * 100) + '%';
                this._onloadend(done, src);
                this._load();
            },
            _onloadstart: function(){},
            _onloadend: function(){},
            _onend: function(){},
            loadstart: function (handler) {
                if (typeof handler === 'function')
                    this._onloadstart = handler;
                return this;
            },
            loadend: function (handler) {
                if (typeof handler === 'function')
                    this._onloadend = handler;
                return this;
            },
            complete: function (handler) {
                if (typeof handler === 'function')
                    this._onend = handler;
                return this;
            },
            image: function (url, val) {
                if(arguments.length == 1){
                    if(undefined == url) {
                        return images;
                    }
                    var img = images[url];
                    if (img)
                        return img;
                    img = new Image();
                    img.src = url;
                    return img;
                }
                if(arguments.length == 2){
                    images[url] = val;
                }
            }
        }

        var LoaderMsk = function(source, color, cb){
            var style = document.createElement('style');
        style.innerHTML = '@-webkit-keyframes loading{0%{-webkit-transform:rotate(0deg);}100%{-webkit-transform:rotate(360deg);}}@-moz-keyframes loading{0%{-moz-transform:rotate(0deg);}100%{-moz-transform:rotate(360deg);}}@-o-keyframes loading{0%{-o-transform:rotate(0deg);}100%{-o-transform:rotate(360deg);}}@-ms-keyframes loading{0%{-ms-transform:rotate(0deg);}100%{-ms-transform:rotate(360deg);}}@keyframes loading{0%{transform:rotate(0deg);}100%{transform:rotate(360deg);}}' + 
                           '.mp_loading{position:absolute; width:100%; height:100%; overflow:hidden; background-color:#E44B46; left:0; top:0; -webkit-transform-style:preserve-3d; z-index:1;}' +
                           '.mp_loading_clip{position:absolute; left:50%; top:50%; width:60px; height:60px; margin:-30px 0 0 -30px; overflow:hidden;  -webkit-animation:loading 1.2s linear infinite; -moz-animation:loading 1.2s linear infinite; -o-animation:loading 1.2s linear infinite; -ms-animation:loading 1.2s linear infinite; animation:loading 1.2s linear infinite;}' +
                           '.mp_loading_bar{position:absolute; left:0; top:0; width: 54px;height: 54px; border-radius:50px; overflow:hidden; clip: rect(0px,36px,70px,0); background:transparent; border:3px solid #fff; -webkit-mask:-webkit-gradient(linear,0 0,0 100%,from(rgba(255,255,255,1)),to(rgba(255,255,255,0)));}' + 
                           '.mp_loading_txt{width: 100px;height: 30px;line-height: 30px;position: absolute;left: 50%;top: 50%;margin-left: -50px;margin-top: -15px;text-align: center;color: #fff;}';
        document.getElementsByTagName('head')[0].appendChild(style);
            var doc = document,
                args = arguments,
                color = typeof color == 'string' ? color : '#E44B46';
            var _loadDom = doc.getElementById('MP_loading'),
                _txtDom = doc.getElementById('MP_precent');
            if(!_loadDom){
                _loadDom = doc.createElement('div');
                _loadDom.className = 'mp_loading';
                _loadDom.innerHTML = '<div class="mp_loading_clip"><div class="mp_loading_bar" style="border-color:"' +color+ '></div></div>';
                _txtDom = doc.createElement('div');
                _txtDom.className = 'mp_loading_txt';
                _loadDom.calssName = 'mp_loading';
                _loadDom.appendChild(_txtDom);
                document.body.appendChild(_loadDom);
            }
            this._loadDom = _loadDom;
            this._txtDom = _txtDom;
            var me = this;
            var ok = args[args.length - 1];
            ok = typeof ok == 'function' ? ok : function(){};
            new Loader(source).loadend(function(percent){
                me._txtDom.innerHTML = this.percent;
            }).complete(function(){
                me._loadDom.style.display = 'none';
                ok.apply(me);
            });
        }

        if(typeof(halo)=='undefined'){
            throw('缺少依赖库 halo.js');
            exports.loader = Loader;
            exports.loadermsk = LoaderMsk;
        }
        halo.add('loader',Loader);
        halo.add('loadermsk',LoaderMsk);
})(window);

(function(exports, m){
	var util = m.util;
	var Event = m.Event;

	var transitionEndEvent = util.transitionEnd().end;
	var RAF = util.RAF;
	var cancelRAF = util.cRAF;
	/*var RAF = function(fn){
		var t = window.setInterval(fn, 100);
		return t;
	}
	var cancelRAF = function(t){
		window.clearInterval(t);
	}*/
	var Scroller = function(selector, opts){
		if(!selector && typeof selector != 'string') return;
		var _s = selector;
		var _opts = opts || {};
		this.init(_s, _opts);
	}

	var _default_opts = {
		Scontainer : '.container',
		hScroll : false,
		vScroll : false,
		momentum : false,
		bounce : false,
		lockDirection : true,
		snap : true,
		nesting : false
	};

	Scroller.prototype = {
		init: function(s, opts){
			this.opts = util.extend({},_default_opts, opts);
			//console.log(this.opts);
			var $el = document.querySelector(s + ' ' + this.opts.Scontainer);
			var $parent = document.querySelector(s);
			this._initUi($el, $parent);			
			this._mixH = $parent.offsetHeight - $el.offsetHeight;
			this._mixW = $parent.offsetWidth - $el.offsetWidth;
			this.$el.style.webkitTransform = 'translate3D(0, 0, 0)';
			if(this.opts.hScroll){
				this.lock = 'lock_y';
			}
			if(this.opts.vScroll){
				this.lock = 'lock_x';
			}
			if(this.opts.hScroll && this.opts.vScroll){
				this.lock = undefined;
			}
			this.initEvent(opts);
		},

		_initUi: function($el, $parent){
			if(this.opts.snap){
				var _pageHeight = $parent.clientHeight;
	        	var _pageWidth = $parent.clientWidth;
				this._clientW = _pageWidth;
				this._clientH = _pageHeight;

				var li = $el.querySelectorAll('li');
				for (var i = 0, len = li.length; i < len; i++){
					li[i].style.width = this._clientW + 'px';
					li[i].style.height = this._clientH + 'px';
				};

				$el.style.height = $el.scrollHeight + 'px';
				$el.style.width = $el.scrollWidth + 'px';
			}else{
				$el.style.height = $el.scrollHeight + 'px';
				$el.style.width = $el.scrollWidth + 'px';
			}
			this.$el = $el;
			this.$parent = $parent;
			this.$li = li;
		},

		_touchstart : function(evt){
			if(this.drag) return;
			this.drag = true;
			target = evt.targetTouches[0];
			this._x = this._x || 0;
			this._y = this._y || 0;

			this.startX = target.pageX;
			this.startY = target.pageY;
			this.srartTime = new Date();

			this._clientX = target.pageX - this._x;
			this._clientY = target.pageY - this._y;
			this.$el.style.webkitTransitionDuration = '0ms';
			this.$el.addEventListener('touchmove', this.update.delegate(this));
			this.$el.addEventListener('touchend', this.clearEvent.delegate(this));
			//this.draw(); //鼠标点击开始
			evt.preventDefault();
			Event.trigger('scrollBefore', this, evt);
		},

		initEvent: function(opts){
			opts = opts || this.opts;
			this.fun = this._touchstart.delegate(this);
			this.$el.addEventListener('touchstart', this.fun);
			if(this.opts.momentum){
				this.$el.addEventListener( transitionEndEvent , function(e){
					this.$el.style.webkitTransitionDuration = '0ms';
					var curr_num = this.currNum;
					var num = curr_num ? -1 * curr_num : '0';
					Event.trigger('scrollEnd', this, num);
				}.delegate(this), false);
			}
			if(opts.scrollEnd)	
				Event.bind('scrollBefore', opts.scrollBefore || util.noop, this);
			if(opts.scrollEnd)	
				Event.bind('scrollEnd', opts.scrollEnd || util.noop, this);
			if(opts.onScroll)
				Event.bind('onScroll', opts.onScroll || util.noop, this);
			if(opts.onTouchEnd)
				Event.bind('onTouchEnd', opts.onTouchEnd || util.noop, this);
		},

		scrollTo:function(options){
			this._x = options.x || this._x;
			this._y = options.y || this._y;
			this._x = this._x || 0;
			this._y = this._y || 0;				
			if(this.opts.snap){
				if(options.y > 0 || options.x > 0){						
					var math = Math.ceil;
				}else{
					var math = Math.floor;
				}
				var curr_num = math( this._y / this._clientH );
				this._x = math( this._x / this._clientW ) * this._clientW;
				this._y = curr_num * this._clientH;
			}
			this.$el.style.webkitTransform = 'translate3d('+ this._x +'px, ' + this._y + 'px, 0px)';
			this.$el.style.webkitTransitionDuration = '300ms';
			var me = this;
			this.currNum = curr_num || 0;
			Event.trigger('onTouchEnd', this, {'x':this._x, 'y':this._y} );
		},
		reset: function(){
			this.$el.style.webkitTransform = 'translate3d(0px, 0px, 0px)';
			this._x = 0;
			this._y = 0;
		},
		draw: function(){
			//没位移就不渲染
			if (!this._shouldMoved) {
				rAF = RAF(this.draw.delegate(this));
				return;
			}
			this.$el.style.webkitTransform = 'translate3D(' + this._x + 'px, ' + this._y + 'px, 0)';

			this._shouldMoved = false;
			rAF = RAF(this.draw.delegate(this));
		},
		clearEvent: function(evt){
			if(!this.drag) return;
			this.drag = false;
			this.$el.removeEventListener("touchmove", this.update, false);
			this.$el.removeEventListener("touchend", this.clearEvent, false);
			//cancelRAF(rAF);
			var target = evt.changedTouches[0];
			var endX = target.pageX;
			var endY = target.pageY;
			
			var _x = this._x,_y = this._y, _dis;
			if(undefined == this.lock || 'lock_x' == this.lock){
				var direction_y = endY - this.startY < 0 ? -1 : 1;
				_dis = direction_y;		
			}

			if(undefined == this.lock || 'lock_y' == this.lock){
				var direction_x = endX - this.startX < 0 ? -1 : 1;
				_dis = direction_x;								
			}


			if(this.opts.momentum){
				var endTime = new Date();
				var disTime = endTime - this.srartTime;
				//disTime = 50000/disTime;
				var _v = Math.abs(_dis / disTime);
				this.$el.style.webkitTransitionDuration = '300ms';	
			}

			if(this.opts.snap){
				if(direction_y > 0 || direction_x > 0){
					var math = Math.ceil;
				}else{
					var math = Math.floor;
				}
				var curr_num;
				curr_num = math( _y / this._clientH );
				_x = math( _x / this._clientW ) * this._clientW;
				_y = curr_num * this._clientH;
				if('lock_y' == this.lock){
					curr_num = math( _x / this._clientW );
				}
						
			}
			if(this.opts.momentum && !this.opts.snap){
				if(undefined == this.lock || 'lock_y' == this.lock)
					_x = _x + _dis / disTime * 10000;
				if(undefined == this.lock || 'lock_x' == this.lock)
					_y = _y + _dis / disTime * 10000;
			}

			if(undefined == this.lock || 'lock_x' == this.lock){
				if(_y > 0) _y = 0;
				if(_y < this._mixH) _y = this._mixH;
			}else if(undefined == this.lock || 'lock_y' == this.lock){
				if(_x > 0) _x = 0;
				if(_x < this._mixW) _x = this._mixW;
			}
			

			this._x = _x;
			this._y = _y;
			this.currNum = curr_num || 0;
			this.$el.style.webkitTransform = 'translate3d('+ _x +'px, ' + _y + 'px, 0px)';

			Event.trigger('onTouchEnd', this, {'x':this._x, 'y':this._y} );

			if(this.opts.nesting){
				this.lock = undefined;
			}
			
			if(this.opts.lockDirection && this.opts.hScroll && this.opts.vScroll){
				this.lock = undefined;
			}
		},		
		update: function(evt){
			if(!this.drag) return;
			var target = evt.targetTouches[0];
			var disY = target.pageY - this._clientY;
			var disX = target.pageX - this._clientX;
			if(disY == disX){
				return;
			}
			var _direction = Math.abs(this._y - disY) > Math.abs(this._x - disX) ? 1 : -1;
			if(this.opts.lockDirection && undefined == this.lock){
				if(_direction == 1){
					this.lock = 'lock_x';
				}else if(_direction == -1){
					this.lock = 'lock_y';
				}
			}
			if(this.lock == 'lock_x' && _direction == -1){
				evt.stopPropagation();
				if(this.opts.nesting){
					this.opts.nesting.drag = false;
				}
				
				return;
			}else if(this.lock == 'lock_y' && _direction == 1){
				evt.stopPropagation();
				if(this.opts.nesting){
					this.opts.nesting.drag = false;
				}
				return;
			}

			if(undefined == this.lock || 'lock_x' == this.lock){				

				if( !this.opts.bounce ){
					if(disY > 0) disY = 0;
					if(disY < this._mixH) disY = this._mixH;
				}else{
					if(disY > 0) disY = disY / 3;
					if(disY < this._mixH) disY = this._mixH + ( disY - this._mixH ) / 3;
				}

				this._y = disY;
			}
			if(undefined == this.lock || 'lock_y' == this.lock){
				
				if( !this.opts.bounce ){
					if(disX > 0) disX = 0;
					if(disX < this._mixW) disX = this._mixW;
				}else{
					if(disX > 0) disX = disX / 3;
					if(disX < this._mixW) disX = this._mixW + ( disX - this._mixW ) / 3;
				}
				this._x = disX;
				
			}			
			this._shouldMoved = true;
			evt.preventDefault();
			
			

			Event.trigger('onScroll', this, {'x':this._x, 'y':this._y} );
		},
		destory:function(){
			this.$el.removeEventListener("touchstart", this.fun);
			this.$parent.style.overflow = 'visible';
		}
	}

	if(typeof halo == 'undefined'){
        throw('缺少依赖库 halo.js');
        exports.yscroll = Scroller;
        return;
    }
        
    halo.add('yscroll',Scroller);
})(window, halo);