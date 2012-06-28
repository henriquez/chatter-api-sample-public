###############################################################
# Chatter related code
###############################################################

# single global namespace for all Chatter related functions 
window.Chatter = { }
window.Chatter.objectHash = {} # hash of Chatter.FeedItems with their ids as the keys
window.Chatter.nextPageUrl = "" # remember paging token used in "more" button

####################################################
# BEGIN Publisher Functions
#################################################### 



####################################################
# Feed
#################################################### 
class Chatter.Feed
  # class vars
  @feedType = "news"
  
  @get: ->
    new Chatter.FeedPage(Chatter.Feed.feedType, null)
    
    
  @nextPage: ->
    page = Chatter.Util.getParameterByName('page', window.Chatter.nextPageUrl)
    new Chatter.FeedPage(Chatter.Feed.feedType, page)  
    

    

####################################################
# FeedPage
#################################################### 
class Chatter.FeedPage
  
  #class vars
  @pageSize = 5  
  
  
  constructor: (feedType, pageParam) ->   
    params = "pageSize=#{Chatter.FeedPage.pageSize}"
    params += if pageParam? then "&page=#{pageParam}" else ""
    $.getJSON("/chatter/feeds/#{feedType}?#{params}", (@apiFeedPage) =>  # apiFeedPage is already parsed into Object   
      if @apiFeedPage.error?
        $("div#chatter-feed-display").append "<div class=\"alert alert-error\">#{@apiFeedPage.error}</div>"
      else  
        items = (for item in @apiFeedPage.items
                  fi = new Chatter.FeedItem(item, @apiFeedPage.instance_url)
                  # JST appears to be unable to access data stored in the dom,
                  # so add in any data needed when rendering -in this case protect
                  # comment forms from CSRF attacks.
                  fi.railsCsrfToken = @apiFeedPage.rails_csrf_token
                  window.Chatter.objectHash[fi.id] = fi  #save for later usage
                  fi )       
        @feedPage = { items: items, nextPageUrl: @apiFeedPage.nextPageUrl }        
        Chatter.FeedPage.render(@feedPage)
        window.Chatter.nextPageUrl = @apiFeedPage.nextPageUrl # save for "more" button
        # show the next page button only if there is a next page
        page_param = Chatter.Util.getParameterByName('page', @feedPage.nextPageUrl)
        if page_param == null  # there is no next page
          $('button#next-feed-page').remove()
        # do initialization that requires the feed to be in the DOM
        # show the file attachment fields when the user clicks "file"
        Chatter.CommentPublisher.attachAllEvents()
        # chatter feed post initialization so textarea recognizes mentions
        Chatter.FeedComponent.attachMentionEvents('textarea.mention')      
    ).error((xhr, textStatus) => Chatter.Error.xhr(xhr.status, textStatus) )
      
    
  
  
  # get and render the 1st page of feed items  
  @render: (feedPage) =>
    $("div#chatter-feed-display").append JST["templates/chatter/feeds"]( items: feedPage.items )

    
    
  





################################################
# PHOTO 
################################################
class Chatter.Photo
  
  constructor: (api_photo) ->
    @smallPhotoUrl = api_photo.smallPhotoUrl
    
 
  
################################################
# USER (encapsulates both user summary and user detail)
################################################
class Chatter.User
  
  
  constructor: (api_user) ->
    @id = api_user.id
    @name = api_user.name
    @type = api_user.type
    # some posts 
    @photo = new Chatter.Photo(api_user.photo)
  

################################################
# GROUP 
################################################
class Chatter.Group
  
  
  constructor: (api_group) ->
    @id = api_group.id
    @name = api_group.name
    @type = api_group.type
    # some posts 
    @photo = new Chatter.Photo(api_group.photo)
    
      
    
################################################
# UNAUTHENTICATED USER 
################################################
class Chatter.UnAuthenticatedUser
  
  
  constructor: (api_user) ->
    @name = api_user.name 
    @type = api_user.type
        
  
################################################
# Record (encapsulates record summary)
################################################
class Chatter.Record
  
  
  constructor: (api_record) ->
    @id = api_record.id
    @name = api_record.name
    # could be any custom object like "account", ...but never "user" when part of a feed item payload
    @type = api_record.type 
    

################################################
# File AKA ContentDocument
################################################
class Chatter.File
  
  constructor: (file) ->
    @id = file.id
    @title = file.title
    @type = file.type    
  
    
################################################
# LIKE
################################################
class Chatter.Like
  #class vars
  @likesToDisplay = 5 # max number of likes to display. The number in the payload could be higher or lower.
  
  
  # build a representation of the like object that we can use elsewhere to 
  # maintain stability across api versions. 
  constructor: (api_like) ->
    @id = api_like.id  # id of the like object used for deletion
    @user = new Chatter.User(api_like.user)

    
  
  # render the list of people who liked this feed item  
  @renderLikesText: (likes, likesTotal, isLikedByCurrentUser, instance_url) ->
    return "" if likes.length is 0
    arr = []
    userLink = (user) ->
      "<a class=\"chatter-user-that-liked\" href=\"#{instance_url}/#{user.id}\">#{Chatter.Util.htmlEscape(user.name)}</a>"
    
    # we want to have Chatter.Like.likesToDisplay names shown
    totalToAdd = Chatter.Like.likesToDisplay
    # add all liking users into the array
    if isLikedByCurrentUser is true
      arr.push "You" # want this as the first name
      totalToAdd--
    for like, i in likes when i < totalToAdd # counting from zero so <
      arr.push userLink(like.user) if like.user.id isnt $.cookie('user_id') 
    
    # insert and in between the names if there are more than 1 but fewer or equal number
    # of likes as the number of names you're willing to display
    decrementer  = 1
    if likes.length > 1 and likes.length <= Chatter.Like.likesToDisplay
      arr.splice -1, 0, " and " # and between last two elements
      decrementer = 2 # tells the comma inserter that the last position is already occupied
    # place comma between all but last two elements (the last two got the "and")
    if likes.length > 2
      if Chatter.Like.likesToDisplay < likes.length
        i = Chatter.Like.likesToDisplay - decrementer
      else 
        i = likes.length - decrementer
      while i isnt 0        
        arr.splice i, 0, ", " 
        i--
    
    # there may be more likes than in the initial like array, so show the count   
    if likesTotal > Chatter.Like.likesToDisplay
      num = likesTotal - Chatter.Like.likesToDisplay
      arr.push " and #{num} other user"
      arr.push "s" if num > 1
    
    # add the action at the end unless there are no likes
    if arr.length isnt 0
      arr.push " liked this"

    # build the string to return
    html = ''
    for el in arr
      html += el
    html
    
  
  @renderLikesContainer: (objectId, likes, likesTotal, isLikedByCurrentUser, instanceUrl) -> 
    if (likes.length > 0)
      """<div class="chatter-likes-container" id="chatter-users-that-liked-#{objectId}" > 
  	        #{ Chatter.Like.renderLikesText(likes, likesTotal, isLikedByCurrentUser, instanceUrl) }
         </div>
  		"""
    else
  	  ""
		

  # called if the user unlikes a feed component he previously liked.
  @unLikeAction: (target, objectName) ->   
    likeId = $(target).attr("like-id")
    objectId =  $(target).attr("object-id")
    $(target).replaceWith(Chatter.FeedComponent.renderTempLink(objectId))
    $.ajax({
      url: "/chatter/likes/#{likeId}",
      type: 'DELETE',
      success: () =>
        $("a#chatter-temp-#{objectId}").replaceWith(Chatter.FeedComponent.renderLikeLink(objectId, objectName))      
        item = window.Chatter.objectHash[objectId]
        # remove the existing like from the item array so we can re render the users that liked
        for i in [0..item.likes.length-1]
          item.likes.splice(i, 1) if item.likes[i].id is likeId
        item.likes.likesTotal -= 1
        item.isLikedByCurrentUser = false
        html = Chatter.Like.renderLikesContainer(objectId, item.likes, item.likesTotal, item.isLikedByCurrentUser, item.instanceUrl)
        $("div#chatter-users-that-liked-foundation-#{objectId}").html(html)
      error:  (xhr, errorText) =>
        Chatter.Error.xhr(xhr.status, errorText)
    })
    
    
  
      
    
################################################
# FeedComponent
################################################
class Chatter.FeedComponent
  # Parent class for Comment and FeedItem
  
  
  constructor: (data, instanceUrl) -> 
    @likes = (new Chatter.Like(api_like, data.id) for api_like in data.likes.likes)
    @likesTotal = data.likes.total
    @likesNextPageUrl = data.likes.NextPageUrl
    @id = data.id
    @messageSegments = data.body.messageSegments
    @myLikeId = data.myLike?.id # myLike may be null
    @isLikedByCurrentUser = data.myLike?
    @instanceUrl = instanceUrl
    # Note that modifiedDate for a feed item is based on the most recent comment date for that
    # feed item, so generally you want to show createdDate like the native UI does.
    @displayDate = Chatter.Util.human_relative_date(data.createdDate)
    @isDeleteRestricted = data.isDeleteRestricted # false if user can't delete the component
    @attachment = Chatter.FeedComponent.createAttachment(data.type, data.attachment)
  
  
  
  
  # render the feed item like link as "like" or "unlike" 
  # called from FeedItem and Comment subclasses
  renderLikeOrUnlikeLink: (objectName) =>
    if @isLikedByCurrentUser
      Chatter.FeedComponent.renderUnLikeLink(@myLikeId, @id, objectName)      
    else
      Chatter.FeedComponent.renderLikeLink(@id, objectName)
      
   
  # parse message segments and return HTML
  # the template does NOT HTML escape this output, because we're returning
  # html, so unlike in other places, the API's output does need to be escaped here.
  segmentsToHtml: () ->
    html = ''
    convert = (segment) => #fat arrow required otherwise instance vars not accessible
        switch segment.type
          when "Text"
            html += Chatter.Util.htmlEscape(segment.text)
          when "Link"
            html += "<a href=\"#{segment.url}\" class=\"chatter-segment-link break-link\">#{Chatter.Util.htmlEscape(segment.text)}</a>"
          when "Mention" # send user back to SFDC user profile
            html += "<a href=\"#{@instanceUrl}/#{segment.user.id}\">#{Chatter.Util.htmlEscape(segment.text)}</a>"
          when "Hashtag"  # TODO turn this into a search link, but requires handling it as a feed request
            html += "<a class=\"hashtag\">#{Chatter.Util.htmlEscape(segment.text)}</a>"
          else # every segment has a text field, this ensures that new unknown segments
               # don't break the app.
            html += Chatter.Util.htmlEscape(segment.text)
    convert(segment) for segment in @messageSegments      
    html  
    
  
  
  # return an attachment instance appropriate to the feedItemType
  @createAttachment: (type, attachmentData, instanceUrl) ->
    switch type
      when "ContentPost", "ContentComment" 
        return new Chatter.ContentPostAttachment(attachmentData, instanceUrl)
      when "LinkPost"
        return new Chatter.LinkPostAttachment(attachmentData, instanceUrl)
      else # new attachment types can pop up even if the API version doesn't change
           # so you must have a failsafe - this also catches the case where
           # there is no attachment
        return null
        
          
    
  @renderLikeLink: (objectId, objectName) ->  # object is the thing being liked, e.g. a feed item or comment 
    "<a id=\"chatter-like-link-#{objectId}\" class=\"chatter-#{objectName}-like-link\" object-id=\"#{objectId}\"  >Like</a>" 
      
  
    # helpers to display like/unlike links for comments and feed items.
  @renderUnLikeLink: (likeId, objectId, objectName) -> 
    "<a id=\"chatter-unlike-link-#{likeId}\" class=\"chatter-#{objectName}-unlike-link\" object-id=\"#{objectId}\" like-id=\"#{likeId}\"  >Unlike</a>"  
          
  
  @renderTempLink: (objectId) -> # link shown to make view response but doesn't enable an action because
                           # the request is in flight
    "<a id=\"chatter-temp-#{objectId}\" class=\"chatter-temp-link\" object-id=\"#{objectId}\">...</a>" 
  
    
  # called when the user likes a component      
  @likeAction: (target, url, objectName, objectId) ->
    # toggle the link so the view seems responsive
    $(target).replaceWith(Chatter.FeedComponent.renderTempLink(objectId))  
    $.ajax({
      url: url, 
      type: 'POST',
      success: (like) => # must use double arrow or data won't be set in unLikeLink      
        # we need to replace the temp link with the real link that enables unlike
        $("a#chatter-temp-#{objectId}").replaceWith(Chatter.FeedComponent.renderUnLikeLink(like.id, objectId, objectName))
        object = window.Chatter.objectHash[objectId]
        object.likes.push(like) # add the returned like and re-render the list of likes
        object.likes.likesTotal += 1
        object.isLikedByCurrentUser = true
        html = Chatter.Like.renderLikesContainer(objectId, object.likes, object.likesTotal, object.isLikedByCurrentUser, object.instanceUrl)
        $("div#chatter-users-that-liked-foundation-#{objectId}").html(html)
      error:  (xhr, errorText) =>
        Chatter.Error.xhr(xhr.status, errorText)
    })
   
    
      
  # add all events that a feed item must support, e.g. likes, delete,...
  # call this any time after the feed is displayed.  Uses delegated
  # events so the individual feed items don't all have to be in the DOM
  # when its called. Applies to any object that is likable.
  @attachLikableEvents: ->
    $("div#chatter-feed-display").on("click", "a.chatter-feeditem-like-link", (event) =>
      Chatter.FeedItem.likeAction( event.target)
    )
    $("div#chatter-feed-display").on("click", "a.chatter-feeditem-unlike-link", (event) =>
      Chatter.Like.unLikeAction( event.target, "feeditem" )
    )
    $("div#chatter-feed-display").on("click", "a.chatter-comment-like-link", (event) =>
      Chatter.Comment.likeAction( event.target )
    )
    $("div#chatter-feed-display").on("click", "a.chatter-comment-unlike-link", (event) =>
      Chatter.Like.unLikeAction( event.target, "comment" )
    )
    
    
  @attachMentionEvents: (selector) ->
    $(selector).elastic()
    $(selector).mentionsInput(
  	  onDataRequest: (mode, query, callback) ->
  	    data = _.filter(window.Chatter.following, (item) -> 
  	      item.name.toLowerCase().indexOf(query.toLowerCase()) > -1)
  	    callback.call(this, data)
  	  minChars: 3   
    )

  
  @attachHiddenControlEvents: ->  
    # show/hide feeditem controls that are used less like delete, bookmark
    $("div#chatter-feed-display").on("mouseenter", "div.chatter-wrapped-body", (event) =>
      # event.target is whichever object mouseenter was first triggered on, which
      # could be any object inside the wrapper.
      hoverArea = $(event.target).parents("div.chatter-wrapped-body")
      if !hoverArea.hasClass("chatter-wrapped-body")
        hoverArea = $(event.target)
      id = hoverArea.attr('object-id')
      deletable = ( window.Chatter.objectHash[id].isDeleteRestricted isnt "false" )
      hoverArea.find("span.chatter-feedcomponent-hover-controls").show() if deletable
    )
    $("div#chatter-feed-display").on("mouseleave", "div.chatter-wrapped-body", (event) =>
      if $(event.target).hasClass("chatter-wrapped-body")
        $(event.target).find("span.chatter-feedcomponent-hover-controls").hide()
      else # event.target will vary depending on which was the last element left
        $(event.target).parents("div.chatter-wrapped-body").find("span.chatter-feedcomponent-hover-controls").hide()
    )



################################################
# FEEDITEM
################################################
class Chatter.FeedItem extends Chatter.FeedComponent 


  constructor: (data, instance_url) ->
    super(data, instance_url)
    # parent could be user summary, record summary, or unauthenticated user
    # this is used for the name/link next to the picture in the feed item title.
    if data.parent.type is 'User'  # user summary
      @parent = new Chatter.User( data.parent ) 
    else if data.parent.type is 'UnauthenticatedUser'  
      @parent = new Chatter.UnAuthenticatedUser( data.parent )
    else if data.parent.type is 'ContentDocument'
      @parent = new Chatter.File( data.parent )
    else
      @parent = new Chatter.Record( data.parent ) # record summary
        
    # actor may be user summary, group, or record summary
    # this is used to display the picture and the picture's link in a feed item
    if data.actor.type is 'User' # user summary 
      @actor = new Chatter.User( data.actor ) 
    else if data.actor.type is 'CollaborationGroup'
      @actor = new Chatter.Group( data.actor )
    else
      @actor = new Chatter.Record( data.actor )
      
    @photoUrl = data.photoUrl # this is the picture displayed with the feed item
    @comments = {}
    @comments.comments = []
    for api_comment in data.comments.comments
      comment = new Chatter.Comment(api_comment, instance_url)
      window.Chatter.objectHash[comment.id] = comment  #save for later usage
      @comments.comments.push(comment)  
    @comments.total = data.comments.total
    @comments.nextPageUrl = data.comments.nextPageUrl
    
  
  
     
  addToTop: ->   
    $("div#chatter-feed-display").prepend JST["templates/chatter/feed_item"]( { item: this } )
 
    
      
  @likeAction: (target) ->
    objectId = $(target).attr('object-id')
    url = "/chatter/feed-items/#{objectId}/likes"
    super target, url, "feeditem", objectId
    
      
  @attachAllEvents: ->
    Chatter.FeedComponent.attachHiddenControlEvents()
    Chatter.FeedComponent.attachLikableEvents()
    Chatter.FeedItem.attachDeleteFeedItemEvent()
    
    
    
  # The isDeleteRestricted key is not reliable - if it is "false" then its still possible
  # that the user may not delete the post.  So the IU may be showing a delete button that
  # when this method is called will return an error.  
  @attachDeleteFeedItemEvent: ->
    $("div#chatter-feed-display").on("click", "i.chatter-feeditem-delete", (event) =>
      objectId = $(event.target).attr('object-id')
      url = "/chatter/feed-items/#{objectId}"      
      $.ajax({
        url: url, 
        type: 'DELETE',
        success:  =>           
          $("div#chatter-feed-item-wrapper-#{objectId}").remove() # remove feed item from DOM
        error: (xhr, errorText, errorThrown) =>
          Chatter.Error.xhr(xhr.status, errorText, errorThrown)
      })
    )


  # render the feed item title in the form
  # logic:
  # if parent is different than the actor, we display both names/links, otherwise just the parent.
  #   if the parent is a group, we render [parent.name] - [actor.name]
  #   else if the parent is a user, we render [actor.name] to [parent.name]. 
  # Note that titles like this are only displayed for feeds that aren't the parent, such as the newsfeed  
  renderTitle: ->
    title = ''
    if @parent.type is 'UnauthenticatedUser'  
      title += Chatter.Util.htmlEscape(@parent.name) # no id / profile so no link
    else if @parent.id isnt @actor.id # we need to display both actor and parent in title
      if @parent.type is 'CollaborationGroup'
        title += """<a href="#{@instanceUrl}/#{@parent.id}" class="break-link">#{Chatter.Util.htmlEscape(@parent.name)}</a> -
                    <a href="#{@instanceUrl}/#{@actor.id}" class="break-link">#{Chatter.Util.htmlEscape(@actor.name)}</a>
                 """
      else if @parent.type is 'User'
        title += """<a href="#{@instanceUrl}/#{@actor.id}" class="break-link">#{Chatter.Util.htmlEscape(@actor.name)}</a> to
                    <a href="#{@instanceUrl}/#{@parent.id}" class="break-link">#{Chatter.Util.htmlEscape(@parent.name)}</a>
                 """
    else # parent and actor are the same
      title += """<a href="#{@instanceUrl}/#{@parent.id}" class="break-link">#{Chatter.Util.htmlEscape(@parent.name)}</a>
               """
    return title


################################################
# ContentPostAttachment
################################################
class Chatter.ContentPostAttachment
   
  # This class is used for content attachments on both feed items and comments
     
  constructor: (data) ->
    if data isnt null
      @description = if data.description isnt null then Chatter.Util.htmlEscape(data.description) else ""
      @downloadUrl = data.downloadUrl
      @hasImagePreview = data.hasImagePreview
      @id = data.id
      @title = Chatter.Util.htmlEscape(data.title)
      @versionId = data.versionId
    else     # file attachments may be null, for example if the file associated with a post
      @description = 'The file was deleted'       # was deleted after the post.
      


  render: (instanceUrl) ->
    # images may not have an image preview if they were just uploaded, so
    # substitute a static image in that case. # like all image requests, 
    # this url must go through a controller proxy method for Oauth
    renditionUrl = if @hasImagePreview 
        Chatter.Util.authenticatedImageUrl("#{instanceUrl}/#{Chatter.Util.apiUrlPreamble()}/chatter/files/#{@id}/rendition")
      else
        "/assets/generic_file_image.jpeg"
    html = ''
    # file attachments may be null, for example if the file was deleted    
    if @versionId?
      html += """
             <div class="chatter-aux-body-inner">
               <a href="#{instanceUrl}/#{@versionId}" >  
                  <img src="#{renditionUrl}" class="chatter-content-post-rendition" width="40" height="30" />
               </a>     
               <div class="chatter-content-post-title-description">
                  <a href="#{instanceUrl}/#{@versionId}" class="break-link">#{@title}</a>
                  <div class="chatter-content-post-actions hidden"><!--TODO: hidden until server implements faster download-->  
                    <a href="/chatter/file/#{@versionId}"><i class="icon-download-alt" ></i>
                      Download</a>
                  </div>

             """
    else
      html += """
                 <div class="chatter-aux-body-inner"> 
                   <img src="#{renditionUrl}" class="chatter-content-post-rendition" width="40" height="30" />    
                   <div class="chatter-content-post-title-description">
              """
    # always return the description so user knows if file was deleted
    html += """     <div class="chatter-wrapped-description">
                       #{@description}
                    </div>   
                 </div>
        
               </div>
           """
    return html


################################################
# LinkPostAttachment
################################################
class Chatter.LinkPostAttachment
  @maxLinkDisplayLength = 60
 
  constructor: (data) ->
    @title = data.title
    @url = data.url
    
    
  render: ->
    if @url.length > Chatter.LinkPostAttachment.maxLinkDisplayLength
      postAmble = "..." 
    else
      postAmble = ""
    return """
           <div class="chatter-aux-body-inner"> 
               <div class="chatter-link-post">    
                  <a class="chatter-link-post-url break-link" href="#{@url}" ><img src="/assets/s.gif">#{@title}</a>                         
                  <br /><span class="chatter-link-text break-link">#{@url.substring(0,Chatter.LinkPostAttachment.maxLinkDisplayLength)} #{postAmble}</span>
               </div>
           </div>
           """
  
    
################################################
# COMMENT
################################################
class Chatter.Comment extends Chatter.FeedComponent
            
  constructor: (api_comment, instance_url) ->
    super(api_comment, instance_url)
    @user = api_comment.user  # unlike FeedItem, the user to display is under the "user" key instead of the "parent" key
    @feedItemId = api_comment.feedItem.id


  @likeAction: (target) ->
    objectId = $(target).attr('object-id')
    url = "/chatter/comments/#{objectId}/likes"
    super target, url, "comment", objectId


  addToList: ->
    $("div#chatter-comments-foundation-#{@feedItemId}").append JST["templates/chatter/comment"]( { comment: this } )
    
    
  @attachAllEvents: ->
    Chatter.Comment.attachDeleteFeedItemEvent()
    
    
    
  # The isDeleteRestricted key is not reliable - if it is "false" then its still possible
  # that the user may not delete the post.  So the IU may be showing a delete button that
  # when this method is called will return an error.  
  @attachDeleteFeedItemEvent: ->
    $("div#chatter-feed-display").on("click", "i.chatter-comment-delete", (event) =>
      objectId = $(event.target).attr('object-id')
      url = "/chatter/comments/#{objectId}"      
      $.ajax({
        url: url, 
        type: 'DELETE',
        success:  =>           
          $("div#chatter-comment-container-#{objectId}").remove() # remove feed item from DOM
        error: (xhr, error_text) =>
          Chatter.Error.xhr(xhr.status, error_text)
      })
    )  
    
    
      
################################################
# FEED ITEM PUBLISHER
################################################
class Chatter.Publisher
  # class vars
  @maxFeedItemChars = 1000
  
  # clear form inputs and error messages after a submission  
  @reset:  ->
    this.hide_spinner()
    $('input#feed-item-file-input').val('')
    $('input#attachment-name').val('') 
    $('textarea#attachment-desc').val('')
    $('input#link-url').val('')     
    $('input#link-name').val('')
    $('div#chatter-feeditem-publisher-error-msgs', window.top.document).html('').css('display', 'none')
    $('form.feeditem textarea.mention').mentionsInput('reset').height(54)
  
  
  
  # validate the set error messages for feeditem and comment input  
  @valid: (text, obj, msgSelector) -> 
    if (text is "") or  (/^\s*$/.test(text)) 
      $(obj).find(msgSelector).html('Please enter text to post').show() 
      false
    else if text.length > Chatter.Publisher.maxFeedItemChars
      $(obj).find(msgSelector).html('Post must be 1000 characters or less').show()
      false  
    else
      true

  
  @show_spinner: ->
    $('img.chatter-feeditem-publisher.chatter-api-submit-spinner').show()
  
  
  @hide_spinner: ->  
    $('img.chatter-feeditem-publisher.chatter-api-submit-spinner').hide()
    
  
  
################################################
# COMMENT PUBLISHER
################################################
class Chatter.CommentPublisher
  # class vars
  @maxFeedItemChars = 1000
  
  
  @attachAllEvents: -> 
    Chatter.CommentPublisher.attachCloseEvents()
    Chatter.CommentPublisher.attachFileEvents()
    Chatter.CommentPublisher.attachShowCommentPublisherEvent()
    Chatter.CommentPublisher.attachValidationEvents()

    
  @attachFileEvents: ->
    $("div#chatter-feed-display").on("click",'a.chatter-show-file-post-fields', (event) => 
      $(event.target).parents('form').find('div.chatter-comment-file-post-fields').show()
      $(event.target).hide()
      $(event.target).parents('form').find('a.chatter-close-file-post-fields').show()
    )  
    
  @attachCloseEvents: ->
    $("div#chatter-feed-display").on("click", 'a.chatter-close-file-post-fields', (event) =>
      $(event.target).parents('form').find('div.chatter-comment-file-post-fields').hide()
      $(event.target).parents('form').find('a.chatter-show-file-post-fields').show()
      $(event.target).hide()  
    )
  
    
    
  @attachValidationEvents: ->
    # For all posts, when form is submitted, post the string with the mentions microformat
    $("div#chatter-feed-display").on("submit", "form.chatter-comment-publisher", (event) => 
      target = $(event.target)
      post = target.find('textarea.mention') 
      itemId = target.attr('item-id')
      if Chatter.Publisher.valid(post.val(), this, "div#chatter-comment-publisher-error-msgs-#{itemId}")  
        Chatter.CommentPublisher.showSpinner(itemId) 
        true
      else
        false # failed validation so don't submit form
    )
  

  @showSpinner: (itemId) ->
    $("img#chatter-api-submit-spinner-#{itemId}").show()
   
   
  @hideSpinner: (itemId) ->
    $("img#chatter-api-submit-spinner-#{itemId}").hide()  
   
   
  # if the user clicks "comment" on a feed item, display the comment publisher. 
  @attachShowCommentPublisherEvent: ->
    $("div#chatter-feed-display").on("click", "a.chatter-feed-item-comment-toggle", (event) =>
      objectId = $(event.target).attr('object-id')
      $("div#chatter-comment-publisher-#{objectId}").removeClass('chatter-hide')  
      txtarea = $("textarea#comment-body-#{objectId}")
      txtarea.focus().change()
      Chatter.FeedComponent.attachMentionEvents(txtarea)
      $(event.target).remove()
    )


  # hide / empty everything that a publish event might have shown.
  @reset: (feedItemId) ->
    $("form#chatter-comment-publisher-#{feedItemId} textarea.mention", window.top.document).mentionsInput('reset').height(35)
    Chatter.CommentPublisher.hideSpinner(feedItemId)
    $("div#chatter-comment-file-post-fields-#{feedItemId}", window.top.document).hide() # close the file dialog
    $("div#chatter-comment-publisher-error-msgs-#{feedItemId}", window.top.document).hide()
    # swap out close link for file link
    $("a#chatter-show-file-post-fields-#{feedItemId}", window.top.document).show()
    $("a#chatter-close-file-post-fields-#{feedItemId}", window.top.document).hide()
    # clear out the name and desc and file fields.
    $("div#chatter-comment-file-post-fields-#{feedItemId} input", window.top.document).val('')
    $("div#chatter-comment-file-post-fields-#{feedItemId} textarea", window.top.document).val('')
    $("div#chatter-publisher-error-msgs-#{feedItemId}", window.top.document).html('').css('display', 'none')



################################################
# ERROR
################################################
class Chatter.Error
  
  @xhr: (httpStatus, errorText, errorThrown ) ->
    console.log "error status=#{httpStatus}, error message=#{errorThrown}"
    if httpStatus is 401 # session expired or bad token so re-authenticate
      window.location = '/'
    else if httpStatus is 403 # you don't have permission (e.g. to delete a feed item) so alert.       
      alert("You don't have permission to do that")
    else # everything else
      alert(errorThrown)
    
    
     
################################################
# UTIL
################################################
class Chatter.Util
  
  #class variables
  @apiVersion = "25.0"
  
  
  @apiUrlPreamble: ->
    "services/data/v#{Chatter.Util.apiVersion}"
  
  
  @getParameterByName: (name, url) ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
    regexS = "[\\?&]" + name + "=([^&#]*)"
    regex = new RegExp(regexS)
    results = regex.exec(url)
    if !results?
      null
    else
      decodeURIComponent( results[1].replace(/\+/g, " ") )  


  
  @htmlEscape: (value) ->
    ('' + value).replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
               


  # builds URL that proxies image requests through controller to add token to header
  @authenticatedImageUrl: (raw_url) ->
    "/chatter/users/photo?url=#{raw_url}" 
    

  @human_relative_date: (api_date) ->
    Date.create(api_date).relative()
    




       
####################################################
# initialization code on window load
####################################################

$ = jQuery # local var for use with jQuery - works even if
# noConflict is set elsewhere
$ ->  # shortcut for $(document).ready..
  # only run if we're showing chatter sidebar
  if $('div.chatter-outer-foundation').length > 0
    ################# publisher related initialization ################
    # follower list in format required by mention picker, may also be used for follower lists. 
    # see http://podio.github.com/jquery-mentions-input/
    Chatter.following = []
    
    # get and save the following list for context user
    $.getJSON("/chatter/users/mentions", {}, (followedUsers) ->
      # TODO check if already in local storage, if not get and save it
      window.Chatter.following = followedUsers)
  
    # drop in placeholder into post textarea
    $('textarea.mention').attr('placeholder', 'What are you working on?')
  
    # For all posts, when form is submitted, post the string with the mentions microformat
    $("form.feeditem").submit (event) => 
      target = $(event.target)
      post = target.find('textarea.mention') 
      post.mentionsInput('val', (text) ->      
        target.find('textarea.hidden').val(text)   #substitute mentions format into the hidden textarea       
      )
      if Chatter.Publisher.valid(post.val(), this, 'div#chatter-feeditem-publisher-error-msgs')  
        Chatter.Publisher.show_spinner() 
        true
      else
        false # failed validation so don't submit form

    ############### feed display related initialization ################
    # render the user's news feed
    feedPage = Chatter.Feed.get()
  
    $('button#next-feed-page').click -> 
      Chatter.Feed.nextPage()
   
    Chatter.FeedItem.attachAllEvents()
    Chatter.Comment.attachAllEvents()
  
  

    
    
####################################################
# End Initialization Code
#################################################### 




   
    


