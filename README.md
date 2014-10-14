
Getting Redis to work, OSX
It's a little funky, which is why its useful to run under something like Vagrant.
If not, $brew install vagrant.
Then $redis-server in a second terminal window. OR make sure it launches at boot: 
http://naleid.com/blog/2011/03/05/running-redis-as-a-user-daemon-on-osx-with-launchd/


Getting an Instagram Oauth Token
There's no way around this, you'll need to register an app with Instagram so you can get a client ID and a client secret. 

Once you do that, you can go through the pain of writing the front-end oauth route, or do this! You'll need to remember client-id, client-secret, and redirect-uri from above.

1. Use the following address:
GET the following:
https://api.instagram.com/oauth/authorize/?client_id=CLIENT-ID&redirect_uri=REDIRECT-URI&response_type=code
It will respond with a code. Write that down. 

2. Once you have the code param from above, enter the following cURL:
curl -F 'client_id=CLIENT-ID' -F 'client_secret=CLIENT-SECRET' -F 'grant_type=authorization_code' -F 'redirect_uri=REDIRECT-URI' -F 'code=CODE' -F 'aspect=media' https://api.instagram.com/oauth/access_token

3. Your cURL will return JSON like this:
{"access_token":"ACCESS-TOKEN","user":{"username":"gxrobillard","bio":"Humorist. Open Sourcerer. Mad Soccer Dad. Some assembly required.","website":"http:\/\/alldaycoffee.net","profile_picture":"http:\/\/images.ak.instagram.com\/profiles\/profile_31741931_75sq_1334701202.jpg","full_name":"G. Xavier Robillard","id":"31741931"}}