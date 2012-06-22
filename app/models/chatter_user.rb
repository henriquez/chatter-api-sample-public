# /chatter/user portions of the Chatter REST API
class ChatterUser
  
  # all class methods since there is no local db row
  class << self
  
    # get the context user's following users (filter out files and records)
    def following(client, current_user, subject_id="me")
      url = "/services/data/v#{client.version}/chatter/users/#{subject_id}/following?pageSize=1000"
      # need to 
      #  1. use the following key 
      #  2. go pick out the 'subject' in each element and put that into a collection
      #  3. filter out subjects that don't have a 'type' key == "User"
      #  4. convert back to JSON, structuring in the user id, name, and profile photo like 
      # is required by the mentions plugin. (see the code in Apex)
      result = JSON.parse(client.http_get(url).body)
      response = []
      result['following'].each do |subscription|
        if subscription['subject']['type'] == 'User'
          response << {'id' => subscription['subject']['id'],
                       'name' => subscription['subject']['name'],
                       'avatar' => "#{subscription['subject']['photo']['smallPhotoUrl']}?oauth_token=#{current_user.access_token}",
                       'type' => 'user' # this must be the same as what the ChatterMention class uses to parse the microformat
                      }            
        end
        
      end
      response.to_json
    end 
     
     
  end
  
end