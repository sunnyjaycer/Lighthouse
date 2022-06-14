function SnackBar(t){var n,e,s,a,i,o=this;function c(){switch(_Options.position){case"bl":return"js-snackbar-container--bottom-left";case"tl":return"js-snackbar-container--top-left";case"tr":return"js-snackbar-container--top-right";case"tc":case"tm":return"js-snackbar-container--top-center";case"bc":case"bm":return"js-snackbar-container--bottom-center";default:return"js-snackbar-container--bottom-right"}}this.Open=function(){var t=function(){const t=window.getComputedStyle(i);return a.scrollHeight+parseFloat(t.getPropertyValue("padding-top"))+parseFloat(t.getPropertyValue("padding-bottom"))}();e.style.height=t+"px",e.style.opacity=1,e.style.marginTop="5px",e.style.marginBottom="5px",e.addEventListener("transitioned",(function(){e.removeEventListener("transitioned",arguments.callee),e.style.height=null}))},this.Close=function(){n&&clearInterval(n);var t=e.scrollHeight,a=e.style.transition;e.style.transition="",requestAnimationFrame((function(){e.style.height=t+"px",e.style.opacity=1,e.style.marginTop="0px",e.style.marginBottom="0px",e.style.transition=a,requestAnimationFrame((function(){e.style.height="0px",e.style.opacity=0}))})),setTimeout((function(){s.removeChild(e)}),1e3)},_Options={message:t?.message??"Operation performed successfully.",dismissible:t?.dismissible??!0,timeout:t?.timeout??5e3,status:t?.status?t.status.toLowerCase().trim():"",actions:t?.actions??[],fixed:t?.fixed??!1,position:t?.position??"br",container:t?.container??document.body,width:t?.width,speed:t?.speed,icon:t?.icon},function(){var t=a();function n(t){for(var n,s=c(),a=0;a<t.children.length;a++)if(1===(n=t.children.item(a)).nodeType&&n.classList.length>0&&n.classList.contains("js-snackbar-container")&&n.classList.contains(s))return n;return e(t)}function e(t){return container=document.createElement("div"),container.classList.add("js-snackbar-container"),_Options.fixed&&container.classList.add("js-snackbar-container--fixed"),t.appendChild(container),container}function a(){return"object"==typeof _Options.container?_Options.container:document.getElementById(_Options.container)}void 0===t&&(console.warn("SnackBar: Could not find target container "+_Options.container),t=document.body),s=n(t)}(),function(){s.classList.add(c());var t="js-snackbar-container--fixed";_Options.fixed?s.classList.add(t):s.classList.remove(t)}(),e=function(){var t=e(),n=s();return t.appendChild(n),t;function e(){var t=document.createElement("div");return t.classList.add("js-snackbar__wrapper"),t.style.height="0px",t.style.opacity="0",t.style.marginTop="0px",t.style.marginBottom="0px",p(t),u(t),t}function s(){var t=document.createElement("div");return t.classList.add("js-snackbar","js-snackbar--show"),c(t),r(t),d(t),l(t),t}function c(t){if(_Options.status){var n=document.createElement("span");n.classList.add("js-snackbar__status"),e(n,t),s(n,t),t.appendChild(n)}function e(t,n){switch(_Options.status){case"success":case"green":n.classList.add("js-snackbar--success--outer"),t.classList.add("js-snackbar--success");break;case"warning":case"alert":case"orange":n.classList.add("js-snackbar--warning--outer"),t.classList.add("js-snackbar--warning");break;case"danger":case"error":case"red":n.classList.add("js-snackbar--danger--outer"),t.classList.add("js-snackbar--danger");break;default:n.classList.add("js-snackbar--info--outer"),t.classList.add("js-snackbar--info")}}function s(t,n){if(_Options.icon){var e=document.createElement("span");switch(e.classList.add("js-snackbar__icon"),_Options.icon){case"exclamation":case"warn":case"danger":e.innerText="!";break;case"info":case"question":case"question-mark":e.innerText="?";break;case"plus":case"add":e.innerText="+";break;default:_Options.icon.length>1&&console.warn("Invalid icon character provided: ",_Options.icon),e.innerText=_Options.icon.substr(0,1)}t.appendChild(e)}}}function r(t){(i=document.createElement("div")).classList.add("js-snackbar__message-wrapper"),(a=document.createElement("span")).classList.add("js-snackbar__message"),a.innerHTML=_Options.message,i.appendChild(a),t.appendChild(i)}function d(t){if("object"==typeof _Options.actions)for(var n=0;n<_Options.actions.length;n++)e(t,_Options.actions[n]);function e(t,n){var e=document.createElement("span");e.classList.add("js-snackbar__action"),e.textContent=n.text,"function"==typeof n.function?!0===n.dismiss?e.onclick=function(){n.function(),o.Close()}:e.onclick=n.function:e.onclick=o.Close,t.appendChild(e)}}function l(t){if(_Options.dismissible){var n=document.createElement("span");n.classList.add("js-snackbar__close"),n.innerText="×",n.onclick=o.Close,t.appendChild(n)}}function p(t){_Options.width&&(t.style.width=_Options.width)}function u(t){const{speed:n}=_Options;switch(typeof n){case"number":t.style.transitionDuration=n+"ms";break;case"string":t.style.transitionDuration=n}}}(),s.appendChild(e),!1!==_Options.timeout&&_Options.timeout>0&&(n=setTimeout(o.Close,_Options.timeout)),o.Open()}