console.log("wechet extension injected!");
selector = "#listContainer .message_item"
targetUrl = "http://42.120.22.130/wechatInDBTest.php";
canvas = document.createElement("canvas");
canvas.id = '_wcInject_wrapperCanvas';
canvas.width = canvas.height = 132;
document.body.appendChild(canvas);
canvas.style['display'] = 'none';
messageBox = document.createElement('div');
messageBox.id = "_wcInject_msgBox";
messageBox.innerHTML = "<p id='content'>通知消息</p>";
document.body.appendChild(messageBox);
styleObj = 
  position: 'fixed',
  width: '100px',
  top: '15px',
  right: '30px',
  'z-index': '9999',
  'display': 'none',
  'color': 'darkred',
  'border': '1px solid darkgrey',
  'border-radius': '3px',
  'background-color': 'white',
  'text-align': 'center'

messageBoxJ = $(messageBox);
messageBoxJ.css(styleObj);

updateListeners = ()->
  doms = $(selector)
  #console.log 'doms:',doms
  if doms.length is 0
    window.setTimeout (->
      updateListeners()
      ),200
    return
  for dom in doms
    newButton = document.createElement("button")
    styleObj =
      'margin-top':0
      'background-color':'rgb(176, 202, 248)'
      'border':'none'
    $(newButton).css(styleObj)
    $(newButton).hover((->
      $(@).css('background-color','rgb(186, 222, 255)')
      $(@).css('cursor','pointer')
      )
    ,(->
      $(@).css('background-color','rgb(176, 202, 248)')
      $(@).css('cursor','auto')
      ))
    newButton.className = "wcInject_catchBtn"
    newButton.innerHTML = "发送此消息"
    newButton.targetDom = dom
    newButton.onclick = ()->
      catchDomInfo @targetDom
    $(dom).find(".message_opr").append(newButton).css('overflow','visible')

catchDomInfo = (targetDom)->
  console.warn 'targetClicked',targetDom
  targetJ = $(targetDom)
  obj =
    id:targetJ.attr "data-id"
    fakeId:targetJ.find('.remark_name').attr "data-fakeid"
    nickName:targetJ.find('.remark_name').text()
    key: "1773771"
    avatarImgDataUrl:do ->
      img = targetJ.find(".avatar img")[0];
      context = canvas.getContext('2d');
      context.drawImage(img, 0, 0);
      dataUrl = canvas.toDataURL('images/jpg');
      str = dataUrl.replace(/^data:image\/(png|jpg);base64,/, "");
      return str;
    contentType:do ->
      #text or img
      J = targetJ.find('.wxMsg')
      if J.find('img').length > 0 then return 'img'
      else return 'text'
  if obj.contentType is 'img'
    obj.content = targetJ.find('.wxMsg img')[0].src
  else
    text = targetJ.find('.wxMsg').text()
    arr = []
    for c in text.split(" ")
      arr.push c if c
    obj.content = arr.join('')
  console.log "发送消息",obj
  $.ajax
    type:'post'
    url:targetUrl
    data:obj
    success:(data,textStatus,jqXHR)->
      console.log 'success'
      sendNotification '发送成功',1000
    error:(data,textStatus,jqXHR)->
      console.error 'post failed'
      sendNotification '发送失败，请联系管理员'
      
sendNotification = (msg,timeout=1000,picUrl='icon.png',title="微信墙管理插件")->
  #console.log(messageBoxJ);
  messageBoxJ.find("#content").text(msg);
  messageBoxJ.slideDown 'fast',->
    window.setTimeout (->
      messageBoxJ.slideUp 'fast'
      ),timeout

window.onload = ->
  updateListeners()

