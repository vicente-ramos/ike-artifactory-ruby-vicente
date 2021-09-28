# IKEArtifactoryGem

Gem to interact with Artifactory using Ruby language.

## API

#### ready
Some IKEArtifactoryGem Client's methods use the *ready* method to check if the instance has valid values in its
attributes:

* *server*: Artifactory server hostname.
* *repo_key*: Repository in Artifactory server.
* *folder_path*: Folder path inside repository.
* *user*: Username to be used to access repository.
* *password*: User's password.

##### Parameters
Do not have parameters.

##### Usage

    irb > artifactory = IKEArtifactoryGem::Client.new()
    => #<IKEArtifactoryGem::Client:0x00007f9b20ce81b0 @server=nil, @repo_key=nil, @folder_path=nil, @user=nil, @password=nil>
    irb > artifactory.ready?
    => false

##### Returns
True if the instance has valid values in its attributes. False in any other case


#### get_days_old
Returns the days since the last update of the given object. 

##### Parameters
* *object_path*: The full path to the object: folder_path/directory/.../object.

##### Usage

    irb > artifactory = IKEArtifactoryGem::Client.new()
    ...
    irb > artifactory.get_days_old 'ib/fedora/34'

##### Returns
The amount of days since the last update.

#### evaluate_container_image
This method evaluates if the given container image (path in artifactory repository) meets the given conditions. Returns
boolean:

* *true*: The given container image meet the conditions.
* *false*: The given container images do not meet the conditions.

##### Parameters:

* *image*: Path to the folder containing container image tags. Path without server host name.
* *tag*: Tag of container image to be evaluated.
* *production_images*: Lists with production container image tags. Any tag in this list will satisfy the conditions.
* *days_old*: The number of days (since modified) before removing any other images (aka pulled with a user different to
  *service_account*).

##### Usage

    irb > artifactory = IKEArtifactoryGem::Client.new()
    ...
    irb > artifactory.evaluate_container_image 'amos', '<some_tag>', [<tag1>, ..., <tagN>], 30

##### Returns
True when the *tag* of the *image* meets the given conditions. false in any other case.

#### get_object_info
Returns a hash with information about the given object.

##### Parameters:

* *object_path*: The full path to the object: folder_path/directory/.../object.

##### Usage

    irb > artifactory = IKEArtifactoryGem::Client.new()
    ...
    irb > artifactory.get_object_info 'ib/fedora/34'

##### Returns
Hash with object's information


#### delete_object
Remove the given object (file or folder) from repository.

##### Parameters:

* *object_path*: The full path to the object: folder_path/directory/.../object.

##### Usage

    irb > artifactory = IKEArtifactoryGem::Client.new()
    ...
    irb > artifactory.delete_object 'ib/fedora/34'

##### Returns
True in case of deleting the object. False in any other case
