#!/usr/bin/perl

use Redditor::Client;
use JSON;

my $client_id       = "x";
my $secret          = "x";
my $username        = "x";
my $password        = "x";

my $reddit = new Redditor::Client(
    user_agent      => 'reddit_main.pl 1.0 by /u/shortl4ndo',
    client_id       => $client_id,
    secret          => $secret,
    username        => $username,
    password        => $password,
);

if (!$ARGV[0] || !defined $ARGV[0] || $ARGV[0] =~ /^$/) {
	die "please use a search query, first word will become the subreddit to search in.\nMust escape spaces with\\ \n";
}

my ($subreddit) = $ARGV[0];
($subreddit) =~ m/^(\w+)/;
$subreddit = $1;

my $search_query = $ARGV[0];
$search_query =~ s/$subreddit//;
$search_query =~ s/\\//g;
$search_query =~ s/ //;

if(!defined $search_query || $search_query =~ /^$/) {
	die "please include more words to search with\n";
}

my $data_res = $reddit->search_api(sub=>$subreddit, q=>$search_query);

my $response = random_post($data_res);
if(!defined $response || $response eq "") {
	print random_post($data_res);
}
else {
	print $response;
}

sub random_post {
	my ($data) = @_;
	my $rand = int(rand(100));
	my @array_data = @{decode_json($data)->{data}->{children}};
	my $rand = int(rand(scalar @array_data));
	my $counter;
	my $id36;
	my $subreddit;
	foreach my $data (@array_data) {
		if($counter++ =~ /^($rand)$/) {
			$id36 = $data->{data}->{id};
			$subreddit = $data->{data}->{subreddit};
			last;
		}
	}
	return get_comment_data($subreddit, $id36);
}

sub get_comment_data {
	my ($sub, $id) = @_;
	my $data_res = $reddit->get_post_comments(sub=>$sub, id=>$id);
	my @comment_data = @{@{decode_json($data_res)}[1]->{data}{children}};
	my $size = scalar @comment_data;
	my $rand_comment = int(rand($size)); # gets lower tier comments which aren't necessarily quality
	my $counter;
	foreach my $comment (@comment_data) {
		if ($counter++ =~ /^($rand_comment)$/) {
			my $resp = $comment->{data}->{body};
			return $resp;
			last;
		}
	}
}