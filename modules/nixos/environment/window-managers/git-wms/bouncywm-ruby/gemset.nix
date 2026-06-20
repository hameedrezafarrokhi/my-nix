{
  coderay = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15vav4bhcc2x3jmi3izb11l4d9f3xv8hp2fszb7iqmpsccv1pz4y";
      type = "gem";
    };
    version = "1.1.2";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10ay35dm0lkcqprsiya6q2kwvyid884102ryipr4vrk790yfp8kd";
      type = "gem";
    };
    version = "1.11.3";
  };
  method_source = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pviwzvdqd90gn6y7illcdd9adapw8fczml933p5vl739dkvl3lq";
      type = "gem";
    };
    version = "0.9.2";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00rm71x0r1jdycwbs83lf9l6p494m99asakbvqxh8rz7zwnlzg69";
      type = "gem";
    };
    version = "0.12.2";
  };
  xlib = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fnfc923n0rnbbw5wh6n9wz6zk6kn109if6qiwf9xjzy0j5y319v";
      type = "gem";
    };
    version = "1.2.0";
  };
  xlib-objects = {
    dependencies = ["xlib" "xlib-xinput2"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1267cpbsn3s3r3gqszxbnndhvpzb0ngq0lamv8wyh7d7ki9bmf51";
      type = "gem";
    };
    version = "0.7.6";
  };
  xlib-xinput2 = {
    dependencies = ["xlib"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04yc349s0nq9plya20nhnzlqchw5jxa021a8mxjadf9wg2zg073n";
      type = "gem";
    };
    version = "1.0.0";
  };
}
