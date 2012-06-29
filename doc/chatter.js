var $,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

window.Chatter = {};

window.Chatter.objectHash = {};

window.Chatter.nextPageUrl = "";

Chatter.Feed = (function() {

  function Feed() {}

  Feed.feedType = "news";

  Feed.get = function() {
    return new Chatter.FeedPage(Chatter.Feed.feedType, null);
  };

  Feed.nextPage = function() {
    var page;
    page = Chatter.Util.getParameterByName('page', window.Chatter.nextPageUrl);
    return new Chatter.FeedPage(Chatter.Feed.feedType, page);
  };

  return Feed;

})();

Chatter.FeedPage = (function() {

  FeedPage.pageSize = 5;

  function FeedPage(feedType, pageParam) {
    var params,
      _this = this;
    params = "pageSize=" + Chatter.FeedPage.pageSize;
    params += pageParam != null ? "&page=" + pageParam : "";
    $.getJSON("/chatter/feeds/" + feedType + "?" + params, function(apiFeedPage) {
      var fi, item, items, page_param;
      _this.apiFeedPage = apiFeedPage;
      if (_this.apiFeedPage.error != null) {
        return $("div#chatter-feed-display").append("<div class=\"alert alert-error\">" + _this.apiFeedPage.error + "</div>");
      } else {
        items = (function() {
          var _i, _len, _ref, _results;
          _ref = this.apiFeedPage.items;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            fi = new Chatter.FeedItem(item, this.apiFeedPage.instance_url);
            fi.railsCsrfToken = this.apiFeedPage.rails_csrf_token;
            window.Chatter.objectHash[fi.id] = fi;
            _results.push(fi);
          }
          return _results;
        }).call(_this);
        _this.feedPage = {
          items: items,
          nextPageUrl: _this.apiFeedPage.nextPageUrl
        };
        Chatter.FeedPage.render(_this.feedPage);
        window.Chatter.nextPageUrl = _this.apiFeedPage.nextPageUrl;
        page_param = Chatter.Util.getParameterByName('page', _this.feedPage.nextPageUrl);
        if (page_param === null) $('button#next-feed-page').remove();
        Chatter.CommentPublisher.attachAllEvents();
        return Chatter.FeedComponent.attachMentionEvents('textarea.mention');
      }
    }).error(function(xhr, textStatus) {
      return Chatter.Error.xhr(xhr.status, textStatus);
    });
  }

  FeedPage.render = function(feedPage) {
    return $("div#chatter-feed-display").append(JST["templates/chatter/feeds"]({
      items: feedPage.items
    }));
  };

  return FeedPage;

}).call(this);

Chatter.Photo = (function() {

  function Photo(api_photo) {
    this.smallPhotoUrl = api_photo.smallPhotoUrl;
  }

  return Photo;

})();

Chatter.User = (function() {

  function User(api_user) {
    this.id = api_user.id;
    this.name = api_user.name;
    this.type = api_user.type;
    this.photo = new Chatter.Photo(api_user.photo);
  }

  return User;

})();

Chatter.Group = (function() {

  function Group(api_group) {
    this.id = api_group.id;
    this.name = api_group.name;
    this.type = api_group.type;
    this.photo = new Chatter.Photo(api_group.photo);
  }

  return Group;

})();

Chatter.UnAuthenticatedUser = (function() {

  function UnAuthenticatedUser(api_user) {
    this.name = api_user.name;
    this.type = api_user.type;
  }

  return UnAuthenticatedUser;

})();

Chatter.Record = (function() {

  function Record(api_record) {
    this.id = api_record.id;
    this.name = api_record.name;
    this.type = api_record.type;
  }

  return Record;

})();

Chatter.File = (function() {

  function File(file) {
    this.id = file.id;
    this.title = file.title;
    this.type = file.type;
  }

  return File;

})();

Chatter.Like = (function() {

  Like.likesToDisplay = 5;

  function Like(api_like) {
    this.id = api_like.id;
    this.user = new Chatter.User(api_like.user);
  }

  Like.renderLikesText = function(likes, likesTotal, isLikedByCurrentUser, instance_url) {
    var arr, decrementer, el, html, i, like, num, totalToAdd, userLink, _i, _len, _len2;
    if (likes.length === 0) return "";
    arr = [];
    userLink = function(user) {
      return "<a class=\"chatter-user-that-liked\" href=\"" + instance_url + "/" + user.id + "\">" + (Chatter.Util.htmlEscape(user.name)) + "</a>";
    };
    totalToAdd = Chatter.Like.likesToDisplay;
    if (isLikedByCurrentUser === true) {
      arr.push("You");
      totalToAdd--;
    }
    for (i = 0, _len = likes.length; i < _len; i++) {
      like = likes[i];
      if (i < totalToAdd) {
        if (like.user.id !== $.cookie('user_id')) arr.push(userLink(like.user));
      }
    }
    decrementer = 1;
    if (likes.length > 1 && likes.length <= Chatter.Like.likesToDisplay) {
      arr.splice(-1, 0, " and ");
      decrementer = 2;
    }
    if (likes.length > 2) {
      if (Chatter.Like.likesToDisplay < likes.length) {
        i = Chatter.Like.likesToDisplay - decrementer;
      } else {
        i = likes.length - decrementer;
      }
      while (i !== 0) {
        arr.splice(i, 0, ", ");
        i--;
      }
    }
    if (likesTotal > Chatter.Like.likesToDisplay) {
      num = likesTotal - Chatter.Like.likesToDisplay;
      arr.push(" and " + num + " other user");
      if (num > 1) arr.push("s");
    }
    if (arr.length !== 0) arr.push(" liked this");
    html = '';
    for (_i = 0, _len2 = arr.length; _i < _len2; _i++) {
      el = arr[_i];
      html += el;
    }
    return html;
  };

  Like.renderLikesContainer = function(objectId, likes, likesTotal, isLikedByCurrentUser, instanceUrl) {
    if (likes.length > 0) {
      return "<div class=\"chatter-likes-container\" id=\"chatter-users-that-liked-" + objectId + "\" > \n  	        " + (Chatter.Like.renderLikesText(likes, likesTotal, isLikedByCurrentUser, instanceUrl)) + "\n</div>";
    } else {
      return "";
    }
  };

  Like.unLikeAction = function(target, objectName) {
    var likeId, objectId,
      _this = this;
    likeId = $(target).attr("like-id");
    objectId = $(target).attr("object-id");
    $(target).replaceWith(Chatter.FeedComponent.renderTempLink(objectId));
    return $.ajax({
      url: "/chatter/likes/" + likeId,
      type: 'DELETE',
      success: function() {
        var html, i, item, _ref;
        $("a#chatter-temp-" + objectId).replaceWith(Chatter.FeedComponent.renderLikeLink(objectId, objectName));
        item = window.Chatter.objectHash[objectId];
        for (i = 0, _ref = item.likes.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
          if (item.likes[i].id === likeId) item.likes.splice(i, 1);
        }
        item.likes.likesTotal -= 1;
        item.isLikedByCurrentUser = false;
        html = Chatter.Like.renderLikesContainer(objectId, item.likes, item.likesTotal, item.isLikedByCurrentUser, item.instanceUrl);
        return $("div#chatter-users-that-liked-foundation-" + objectId).html(html);
      },
      error: function(xhr, errorText) {
        return Chatter.Error.xhr(xhr.status, errorText);
      }
    });
  };

  return Like;

})();

Chatter.FeedComponent = (function() {

  function FeedComponent(data, instanceUrl) {
    this.renderLikeOrUnlikeLink = __bind(this.renderLikeOrUnlikeLink, this);
    var api_like, _ref;
    this.likes = (function() {
      var _i, _len, _ref, _results;
      _ref = data.likes.likes;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        api_like = _ref[_i];
        _results.push(new Chatter.Like(api_like, data.id));
      }
      return _results;
    })();
    this.likesTotal = data.likes.total;
    this.likesNextPageUrl = data.likes.NextPageUrl;
    this.id = data.id;
    this.messageSegments = data.body.messageSegments;
    this.myLikeId = (_ref = data.myLike) != null ? _ref.id : void 0;
    this.isLikedByCurrentUser = data.myLike != null;
    this.instanceUrl = instanceUrl;
    this.displayDate = Chatter.Util.human_relative_date(data.createdDate);
    this.isDeleteRestricted = data.isDeleteRestricted;
    this.attachment = Chatter.FeedComponent.createAttachment(data.type, data.attachment);
  }

  FeedComponent.prototype.renderLikeOrUnlikeLink = function(objectName) {
    if (this.isLikedByCurrentUser) {
      return Chatter.FeedComponent.renderUnLikeLink(this.myLikeId, this.id, objectName);
    } else {
      return Chatter.FeedComponent.renderLikeLink(this.id, objectName);
    }
  };

  FeedComponent.prototype.segmentsToHtml = function() {
    var convert, html, segment, _i, _len, _ref,
      _this = this;
    html = '';
    convert = function(segment) {
      switch (segment.type) {
        case "Text":
          return html += Chatter.Util.htmlEscape(segment.text);
        case "Link":
          return html += "<a href=\"" + segment.url + "\" class=\"chatter-segment-link break-link\">" + (Chatter.Util.htmlEscape(segment.text)) + "</a>";
        case "Mention":
          return html += "<a href=\"" + _this.instanceUrl + "/" + segment.user.id + "\">" + (Chatter.Util.htmlEscape(segment.text)) + "</a>";
        case "Hashtag":
          return html += "<a class=\"hashtag\">" + (Chatter.Util.htmlEscape(segment.text)) + "</a>";
        default:
          return html += Chatter.Util.htmlEscape(segment.text);
      }
    };
    _ref = this.messageSegments;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      segment = _ref[_i];
      convert(segment);
    }
    return html;
  };

  FeedComponent.createAttachment = function(type, attachmentData, instanceUrl) {
    switch (type) {
      case "ContentPost":
      case "ContentComment":
        return new Chatter.ContentPostAttachment(attachmentData, instanceUrl);
      case "LinkPost":
        return new Chatter.LinkPostAttachment(attachmentData, instanceUrl);
      default:
        return null;
    }
  };

  FeedComponent.renderLikeLink = function(objectId, objectName) {
    return "<a id=\"chatter-like-link-" + objectId + "\" class=\"chatter-" + objectName + "-like-link\" object-id=\"" + objectId + "\"  >Like</a>";
  };

  FeedComponent.renderUnLikeLink = function(likeId, objectId, objectName) {
    return "<a id=\"chatter-unlike-link-" + likeId + "\" class=\"chatter-" + objectName + "-unlike-link\" object-id=\"" + objectId + "\" like-id=\"" + likeId + "\"  >Unlike</a>";
  };

  FeedComponent.renderTempLink = function(objectId) {
    return "<a id=\"chatter-temp-" + objectId + "\" class=\"chatter-temp-link\" object-id=\"" + objectId + "\">...</a>";
  };

  FeedComponent.likeAction = function(target, url, objectName, objectId) {
    var _this = this;
    $(target).replaceWith(Chatter.FeedComponent.renderTempLink(objectId));
    return $.ajax({
      url: url,
      type: 'POST',
      success: function(like) {
        var html, object;
        $("a#chatter-temp-" + objectId).replaceWith(Chatter.FeedComponent.renderUnLikeLink(like.id, objectId, objectName));
        object = window.Chatter.objectHash[objectId];
        object.likes.push(like);
        object.likes.likesTotal += 1;
        object.isLikedByCurrentUser = true;
        html = Chatter.Like.renderLikesContainer(objectId, object.likes, object.likesTotal, object.isLikedByCurrentUser, object.instanceUrl);
        return $("div#chatter-users-that-liked-foundation-" + objectId).html(html);
      },
      error: function(xhr, errorText) {
        return Chatter.Error.xhr(xhr.status, errorText);
      }
    });
  };

  FeedComponent.attachLikableEvents = function() {
    var _this = this;
    $("div#chatter-feed-display").on("click", "a.chatter-feeditem-like-link", function(event) {
      return Chatter.FeedItem.likeAction(event.target);
    });
    $("div#chatter-feed-display").on("click", "a.chatter-feeditem-unlike-link", function(event) {
      return Chatter.Like.unLikeAction(event.target, "feeditem");
    });
    $("div#chatter-feed-display").on("click", "a.chatter-comment-like-link", function(event) {
      return Chatter.Comment.likeAction(event.target);
    });
    return $("div#chatter-feed-display").on("click", "a.chatter-comment-unlike-link", function(event) {
      return Chatter.Like.unLikeAction(event.target, "comment");
    });
  };

  FeedComponent.attachMentionEvents = function(selector) {
    $(selector).elastic();
    return $(selector).mentionsInput({
      onDataRequest: function(mode, query, callback) {
        var data;
        data = _.filter(window.Chatter.following, function(item) {
          return item.name.toLowerCase().indexOf(query.toLowerCase()) > -1;
        });
        return callback.call(this, data);
      },
      minChars: 3
    });
  };

  FeedComponent.attachHiddenControlEvents = function() {
    var _this = this;
    $("div#chatter-feed-display").on("mouseenter", "div.chatter-wrapped-body", function(event) {
      var deletable, hoverArea, id;
      hoverArea = $(event.target).parents("div.chatter-wrapped-body");
      if (!hoverArea.hasClass("chatter-wrapped-body")) hoverArea = $(event.target);
      id = hoverArea.attr('object-id');
      deletable = window.Chatter.objectHash[id].isDeleteRestricted !== "false";
      if (deletable) {
        return hoverArea.find("span.chatter-feedcomponent-hover-controls").show();
      }
    });
    return $("div#chatter-feed-display").on("mouseleave", "div.chatter-wrapped-body", function(event) {
      if ($(event.target).hasClass("chatter-wrapped-body")) {
        return $(event.target).find("span.chatter-feedcomponent-hover-controls").hide();
      } else {
        return $(event.target).parents("div.chatter-wrapped-body").find("span.chatter-feedcomponent-hover-controls").hide();
      }
    });
  };

  return FeedComponent;

})();

Chatter.FeedItem = (function(_super) {

  __extends(FeedItem, _super);

  function FeedItem(data, instance_url) {
    var api_comment, comment, _i, _len, _ref;
    FeedItem.__super__.constructor.call(this, data, instance_url);
    if (data.parent.type === 'User') {
      this.parent = new Chatter.User(data.parent);
    } else if (data.parent.type === 'UnauthenticatedUser') {
      this.parent = new Chatter.UnAuthenticatedUser(data.parent);
    } else if (data.parent.type === 'ContentDocument') {
      this.parent = new Chatter.File(data.parent);
    } else {
      this.parent = new Chatter.Record(data.parent);
    }
    if (data.actor.type === 'User') {
      this.actor = new Chatter.User(data.actor);
    } else if (data.actor.type === 'CollaborationGroup') {
      this.actor = new Chatter.Group(data.actor);
    } else {
      this.actor = new Chatter.Record(data.actor);
    }
    this.photoUrl = data.photoUrl;
    this.comments = {};
    this.comments.comments = [];
    _ref = data.comments.comments;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      api_comment = _ref[_i];
      comment = new Chatter.Comment(api_comment, instance_url);
      window.Chatter.objectHash[comment.id] = comment;
      this.comments.comments.push(comment);
    }
    this.comments.total = data.comments.total;
    this.comments.nextPageUrl = data.comments.nextPageUrl;
  }

  FeedItem.prototype.addToTop = function() {
    return $("div#chatter-feed-display").prepend(JST["templates/chatter/feed_item"]({
      item: this
    }));
  };

  FeedItem.likeAction = function(target) {
    var objectId, url;
    objectId = $(target).attr('object-id');
    url = "/chatter/feed-items/" + objectId + "/likes";
    return FeedItem.__super__.constructor.likeAction.call(this, target, url, "feeditem", objectId);
  };

  FeedItem.attachAllEvents = function() {
    Chatter.FeedComponent.attachHiddenControlEvents();
    Chatter.FeedComponent.attachLikableEvents();
    return Chatter.FeedItem.attachDeleteFeedItemEvent();
  };

  FeedItem.attachDeleteFeedItemEvent = function() {
    var _this = this;
    return $("div#chatter-feed-display").on("click", "i.chatter-feeditem-delete", function(event) {
      var objectId, url;
      objectId = $(event.target).attr('object-id');
      url = "/chatter/feed-items/" + objectId;
      return $.ajax({
        url: url,
        type: 'DELETE',
        success: function() {
          return $("div#chatter-feed-item-wrapper-" + objectId).remove();
        },
        error: function(xhr, errorText, errorThrown) {
          return Chatter.Error.xhr(xhr.status, errorText, errorThrown);
        }
      });
    });
  };

  FeedItem.prototype.renderTitle = function() {
    var title;
    title = '';
    if (this.parent.type === 'UnauthenticatedUser') {
      title += Chatter.Util.htmlEscape(this.parent.name);
    } else if (this.parent.id !== this.actor.id) {
      if (this.parent.type === 'CollaborationGroup') {
        title += "<a href=\"" + this.instanceUrl + "/" + this.parent.id + "\" class=\"break-link\">" + (Chatter.Util.htmlEscape(this.parent.name)) + "</a> -\n<a href=\"" + this.instanceUrl + "/" + this.actor.id + "\" class=\"break-link\">" + (Chatter.Util.htmlEscape(this.actor.name)) + "</a>";
      } else if (this.parent.type === 'User') {
        title += "<a href=\"" + this.instanceUrl + "/" + this.actor.id + "\" class=\"break-link\">" + (Chatter.Util.htmlEscape(this.actor.name)) + "</a> to\n<a href=\"" + this.instanceUrl + "/" + this.parent.id + "\" class=\"break-link\">" + (Chatter.Util.htmlEscape(this.parent.name)) + "</a>";
      }
    } else {
      title += "<a href=\"" + this.instanceUrl + "/" + this.parent.id + "\" class=\"break-link\">" + (Chatter.Util.htmlEscape(this.parent.name)) + "</a>";
    }
    return title;
  };

  return FeedItem;

})(Chatter.FeedComponent);

Chatter.ContentPostAttachment = (function() {

  function ContentPostAttachment(data) {
    if (data !== null) {
      this.description = data.description !== null ? Chatter.Util.htmlEscape(data.description) : "";
      this.downloadUrl = data.downloadUrl;
      this.hasImagePreview = data.hasImagePreview;
      this.id = data.id;
      this.title = Chatter.Util.htmlEscape(data.title);
      this.versionId = data.versionId;
    } else {
      this.description = 'The file was deleted';
    }
  }

  ContentPostAttachment.prototype.render = function(instanceUrl) {
    var html, renditionUrl;
    renditionUrl = this.hasImagePreview ? Chatter.Util.authenticatedImageUrl("" + instanceUrl + "/" + (Chatter.Util.apiUrlPreamble()) + "/chatter/files/" + this.id + "/rendition") : "/assets/generic_file_image.jpeg";
    html = '';
    if (this.versionId != null) {
      html += "<div class=\"chatter-aux-body-inner\">\n  <a href=\"" + instanceUrl + "/" + this.versionId + "\" >  \n     <img src=\"" + renditionUrl + "\" class=\"chatter-content-post-rendition\" width=\"40\" height=\"30\" />\n  </a>     \n  <div class=\"chatter-content-post-title-description\">\n     <a href=\"" + instanceUrl + "/" + this.versionId + "\" class=\"break-link\">" + this.title + "</a>\n     <div class=\"chatter-content-post-actions hidden\"><!--TODO: hidden until server implements faster download-->  \n       <a href=\"/chatter/file/" + this.versionId + "\"><i class=\"icon-download-alt\" ></i>\n         Download</a>\n     </div>\n";
    } else {
      html += "<div class=\"chatter-aux-body-inner\"> \n  <img src=\"" + renditionUrl + "\" class=\"chatter-content-post-rendition\" width=\"40\" height=\"30\" />    \n  <div class=\"chatter-content-post-title-description\">";
    }
    html += "     <div class=\"chatter-wrapped-description\">\n               " + this.description + "\n            </div>   \n         </div>\n\n       </div>";
    return html;
  };

  return ContentPostAttachment;

})();

Chatter.LinkPostAttachment = (function() {

  LinkPostAttachment.maxLinkDisplayLength = 60;

  function LinkPostAttachment(data) {
    this.title = data.title;
    this.url = data.url;
  }

  LinkPostAttachment.prototype.render = function() {
    var postAmble;
    if (this.url.length > Chatter.LinkPostAttachment.maxLinkDisplayLength) {
      postAmble = "...";
    } else {
      postAmble = "";
    }
    return "<div class=\"chatter-aux-body-inner\"> \n    <div class=\"chatter-link-post\">    \n       <a class=\"chatter-link-post-url break-link\" href=\"" + this.url + "\" ><img src=\"/assets/s.gif\">" + this.title + "</a>                         \n       <br /><span class=\"chatter-link-text break-link\">" + (this.url.substring(0, Chatter.LinkPostAttachment.maxLinkDisplayLength)) + " " + postAmble + "</span>\n    </div>\n</div>";
  };

  return LinkPostAttachment;

})();

Chatter.Comment = (function(_super) {

  __extends(Comment, _super);

  function Comment(api_comment, instance_url) {
    Comment.__super__.constructor.call(this, api_comment, instance_url);
    this.user = api_comment.user;
    this.feedItemId = api_comment.feedItem.id;
  }

  Comment.likeAction = function(target) {
    var objectId, url;
    objectId = $(target).attr('object-id');
    url = "/chatter/comments/" + objectId + "/likes";
    return Comment.__super__.constructor.likeAction.call(this, target, url, "comment", objectId);
  };

  Comment.prototype.addToList = function() {
    return $("div#chatter-comments-foundation-" + this.feedItemId).append(JST["templates/chatter/comment"]({
      comment: this
    }));
  };

  Comment.attachAllEvents = function() {
    return Chatter.Comment.attachDeleteFeedItemEvent();
  };

  Comment.attachDeleteFeedItemEvent = function() {
    var _this = this;
    return $("div#chatter-feed-display").on("click", "i.chatter-comment-delete", function(event) {
      var objectId, url;
      objectId = $(event.target).attr('object-id');
      url = "/chatter/comments/" + objectId;
      return $.ajax({
        url: url,
        type: 'DELETE',
        success: function() {
          return $("div#chatter-comment-container-" + objectId).remove();
        },
        error: function(xhr, error_text) {
          return Chatter.Error.xhr(xhr.status, error_text);
        }
      });
    });
  };

  return Comment;

})(Chatter.FeedComponent);

Chatter.Publisher = (function() {

  function Publisher() {}

  Publisher.maxFeedItemChars = 1000;

  Publisher.reset = function() {
    this.hide_spinner();
    $('input#feed-item-file-input').val('');
    $('input#attachment-name').val('');
    $('textarea#attachment-desc').val('');
    $('input#link-url').val('');
    $('input#link-name').val('');
    $('div#chatter-feeditem-publisher-error-msgs', window.top.document).html('').css('display', 'none');
    return $('form.feeditem textarea.mention').mentionsInput('reset').height(54);
  };

  Publisher.valid = function(text, obj, msgSelector) {
    if ((text === "") || (/^\s*$/.test(text))) {
      $(obj).find(msgSelector).html('Please enter text to post').show();
      return false;
    } else if (text.length > Chatter.Publisher.maxFeedItemChars) {
      $(obj).find(msgSelector).html('Post must be 1000 characters or less').show();
      return false;
    } else {
      return true;
    }
  };

  Publisher.show_spinner = function() {
    return $('img.chatter-feeditem-publisher.chatter-api-submit-spinner').show();
  };

  Publisher.hide_spinner = function() {
    return $('img.chatter-feeditem-publisher.chatter-api-submit-spinner').hide();
  };

  return Publisher;

})();

Chatter.CommentPublisher = (function() {

  function CommentPublisher() {}

  CommentPublisher.maxFeedItemChars = 1000;

  CommentPublisher.attachAllEvents = function() {
    Chatter.CommentPublisher.attachCloseEvents();
    Chatter.CommentPublisher.attachFileEvents();
    Chatter.CommentPublisher.attachShowCommentPublisherEvent();
    return Chatter.CommentPublisher.attachValidationEvents();
  };

  CommentPublisher.attachFileEvents = function() {
    var _this = this;
    return $("div#chatter-feed-display").on("click", 'a.chatter-show-file-post-fields', function(event) {
      $(event.target).parents('form').find('div.chatter-comment-file-post-fields').show();
      $(event.target).hide();
      return $(event.target).parents('form').find('a.chatter-close-file-post-fields').show();
    });
  };

  CommentPublisher.attachCloseEvents = function() {
    var _this = this;
    return $("div#chatter-feed-display").on("click", 'a.chatter-close-file-post-fields', function(event) {
      $(event.target).parents('form').find('div.chatter-comment-file-post-fields').hide();
      $(event.target).parents('form').find('a.chatter-show-file-post-fields').show();
      return $(event.target).hide();
    });
  };

  CommentPublisher.attachValidationEvents = function() {
    var _this = this;
    return $("div#chatter-feed-display").on("submit", "form.chatter-comment-publisher", function(event) {
      var itemId, post, target;
      target = $(event.target);
      post = target.find('textarea.mention');
      itemId = target.attr('item-id');
      if (Chatter.Publisher.valid(post.val(), _this, "div#chatter-comment-publisher-error-msgs-" + itemId)) {
        Chatter.CommentPublisher.showSpinner(itemId);
        return true;
      } else {
        return false;
      }
    });
  };

  CommentPublisher.showSpinner = function(itemId) {
    return $("img#chatter-api-submit-spinner-" + itemId).show();
  };

  CommentPublisher.hideSpinner = function(itemId) {
    return $("img#chatter-api-submit-spinner-" + itemId).hide();
  };

  CommentPublisher.attachShowCommentPublisherEvent = function() {
    var _this = this;
    return $("div#chatter-feed-display").on("click", "a.chatter-feed-item-comment-toggle", function(event) {
      var objectId, txtarea;
      objectId = $(event.target).attr('object-id');
      $("div#chatter-comment-publisher-" + objectId).removeClass('chatter-hide');
      txtarea = $("textarea#comment-body-" + objectId);
      txtarea.focus().change();
      Chatter.FeedComponent.attachMentionEvents(txtarea);
      return $(event.target).remove();
    });
  };

  CommentPublisher.reset = function(feedItemId) {
    $("form#chatter-comment-publisher-" + feedItemId + " textarea.mention", window.top.document).mentionsInput('reset').height(35);
    Chatter.CommentPublisher.hideSpinner(feedItemId);
    $("div#chatter-comment-file-post-fields-" + feedItemId, window.top.document).hide();
    $("div#chatter-comment-publisher-error-msgs-" + feedItemId, window.top.document).hide();
    $("a#chatter-show-file-post-fields-" + feedItemId, window.top.document).show();
    $("a#chatter-close-file-post-fields-" + feedItemId, window.top.document).hide();
    $("div#chatter-comment-file-post-fields-" + feedItemId + " input", window.top.document).val('');
    $("div#chatter-comment-file-post-fields-" + feedItemId + " textarea", window.top.document).val('');
    return $("div#chatter-publisher-error-msgs-" + feedItemId, window.top.document).html('').css('display', 'none');
  };

  return CommentPublisher;

})();

Chatter.Error = (function() {

  function Error() {}

  Error.xhr = function(httpStatus, errorText, errorThrown) {
    console.log("error status=" + httpStatus + ", error message=" + errorThrown);
    if (httpStatus === 401) {
      return window.location = '/';
    } else if (httpStatus === 403) {
      return alert("You don't have permission to do that");
    } else {
      return alert(errorThrown);
    }
  };

  return Error;

})();

Chatter.Util = (function() {

  function Util() {}

  Util.apiVersion = "25.0";

  Util.apiUrlPreamble = function() {
    return "services/data/v" + Chatter.Util.apiVersion;
  };

  Util.getParameterByName = function(name, url) {
    var regex, regexS, results;
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    regexS = "[\\?&]" + name + "=([^&#]*)";
    regex = new RegExp(regexS);
    results = regex.exec(url);
    if (!(results != null)) {
      return null;
    } else {
      return decodeURIComponent(results[1].replace(/\+/g, " "));
    }
  };

  Util.htmlEscape = function(value) {
    return ('' + value).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  };

  Util.authenticatedImageUrl = function(raw_url) {
    return "/chatter/users/photo?url=" + raw_url;
  };

  Util.human_relative_date = function(api_date) {
    return Date.create(api_date).relative();
  };

  return Util;

})();

$ = jQuery;

$(function() {
  var feedPage,
    _this = this;
  if ($('div.chatter-outer-foundation').length > 0) {
    Chatter.following = [];
    $.getJSON("/chatter/users/mentions", {}, function(followedUsers) {
      return window.Chatter.following = followedUsers;
    });
    $('textarea.mention').attr('placeholder', 'What are you working on?');
    $("form.feeditem").submit(function(event) {
      var post, target;
      target = $(event.target);
      post = target.find('textarea.mention');
      post.mentionsInput('val', function(text) {
        return target.find('textarea.hidden').val(text);
      });
      if (Chatter.Publisher.valid(post.val(), _this, 'div#chatter-feeditem-publisher-error-msgs')) {
        Chatter.Publisher.show_spinner();
        return true;
      } else {
        return false;
      }
    });
    feedPage = Chatter.Feed.get();
    $('button#next-feed-page').click(function() {
      return Chatter.Feed.nextPage();
    });
    Chatter.FeedItem.attachAllEvents();
    return Chatter.Comment.attachAllEvents();
  }
});