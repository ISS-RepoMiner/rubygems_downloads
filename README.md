## rubygems_downloads

### Usage example

#### Every time using the library, we should initialize a searching session with:


	requrie "./GemMiner.rb"
	citesight = GemMiner.new "citesight"

#### print the basic info of a gem

	In:
	puts citesight.get_info

	Out:
	...

#### print the download times of yesterday

	In:
	puts citesight.get_yesterday_downloads

	Out:
	{"citesight"=>{"0.1.0"=>{"2015-04-05"=>0}, "0.0.4"=>{"2015-04-05"=>0}, "0.0.2"=>{"2015-04-05"=>0}, "0.0.1"=>{"2015-04-05"=>0}}}


#### print the download times accumulated according to version and date

	In:
	puts example.get_versions_downloads_list

	Out:
	{"citesight"=>{"0.1.0"=>{"2015-04-05"=>0, "2015-01-07"=>14, "2015-01-08"=>3, "2015-01-09"=>0, "2015-01-10"=>1, "2015-01-11"=>1, "2015-01-12"=>0, "2015-01-13"=>0, "2015-01-14"=>1,.....}


#### print the downloads times of a gem of specific version in the latest day

	In:
	get_ver_yesterday_downloads (ver)

	Out:
	
