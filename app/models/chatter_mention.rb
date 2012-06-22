class ChatterMention
  attr_accessor :start, :end, :text
  
  # for podio mentions jquery plugin - parses its format
  # use to extract the user id/contact as a capture group 
  MENTION_GROUP_REGEX = /@\[[^\]]{4,}\]\(user:(\w{15,18})\)/
  # use to extract the entire mention format 
  MENTION_REGEX = /@\[[^\]]{4,}\]\(user:\w{15,18}\)/
  
  
  
  def self.extract_mentions(post)
    mentions = []
    cursor = 0
    while match = post.match(MENTION_REGEX, cursor) do 
        mention         = ChatterMention.new
        mention.text    = match[0] # whole matched text
        mention.start   = match.begin(0)
        mention.end     = match.end(0)
        cursor = mention.end
        mentions << mention
    end
    mentions      
  end
  
  
  # Parse the user id out of a string that has one mention in it and return it.
  def self.extract_user_id(mention_str) 
    mention_str[MENTION_GROUP_REGEX,1] # return first capture group in str 
  end
    
    
end