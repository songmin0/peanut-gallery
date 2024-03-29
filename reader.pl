:- module(reader, [r_update_all_ifs/2, r_total_inf/2, r_all_critical_inf/2]).

:- use_module(ubc_restaurants).
:- use_module(rest).

% read_restaurants reads the given restaurant data
read_restaurants :-
    open('ubc-restaurants.txt', read, Str),
    read_file(Str,Lines),
    close(Str),
    print(Lines), nl.

% read_file is true when Stream is at the end
read_file(Stream,[]) :-
    at_end_of_stream(Stream).

%read_file(Stream, Rs) is true when Stream is read properly
read_file(Stream,[X|L]) :-
    \+ at_end_of_stream(Stream),
    read(Stream,X),
    read_file(Stream,L).

% r_name is true when X is a restaurant and Name is the name of the restaurant
r_name(rest(X), Name) :-
    split_string(X, "|", "", [Name|_]).

% r_total_inf is true if the restaurant of name Name has I total food safety infractions
r_total_inf(rest(X), I) :-
    split_string(X, "|", "", [_, _, _, I|_]).

% r_all_critical_inf is true if the restaurant of name Name has I outstanding critical food safety infractions
r_all_critical_inf(rest(X), I) :-
    split_string(X, "|", "", [_, _, _, _, I|_]).

% r_address is true if X is a restaurant and A is the address of the restaurant
r_address(rest(X), A) :-
    split_string(X, "|", "", [_, A|_]).

% restaurant(Name, Address, Phone, Price, Rating, TotalInf, CritInf).

% business_name(B, N) is true when Name is the business's name or is N/A
business_name(Business, "N/A") :- \+ get_dict(name, Business, _).
business_name(Business, Name) :- get_dict(name, Business, Name).

% business_address(B, A) is true when Address is the business's address or is N/A
business_address(Business, "N/A") :- \+ yelp_address(Business, _).
business_address(Business, Address) :- yelp_address(Business, Address).

% business_phone(B, P) is true when Phone is the business's phone or is N/A
business_phone(Business, "N/A") :- \+ get_dict(phone, Business, _).
business_phone(Business, Phone) :- get_dict(phone, Business, Phone).

% business_price(B, PR) is true when Price is the business's price or is N/A
business_price(Business, "N/A") :- \+ get_dict(price, Business, _).
business_price(Business, Price) :- get_dict(price, Business, Price).

% business_rating(B, R) is true when Rating is the business's rating or is N/A
business_rating(Business, "N/A") :- \+ get_dict(rating, Business, _).
business_rating(Business, Rating) :- get_dict(rating, Business, Rating).

% build_restaurant(B, R) is true when Restaurant R contains all essential metadata of Business B
build_restaurant(Yelp_business, restaurant(Name, Address, Phone, Price, Rating, "0", "0")) :-
    business_name(Yelp_business, Name),
    business_address(Yelp_business, Address),
    business_phone(Yelp_business, Phone),
    business_price(Yelp_business, Price),
    business_rating(Yelp_business, Rating).
% build_restaurant(B, R) is true when Restaurant R contains all essential metadata of Business B including total and critical infractions
build_restaurant(Yelp_business, Ubc_business, restaurant(Name, Address, Phone, Price, Rating, TotalInf, CritInf)) :-
    business_name(Yelp_business, Name),
    business_address(Yelp_business, Address),
    business_phone(Yelp_business, Phone),
    business_price(Yelp_business, Price),
    business_rating(Yelp_business, Rating),
    r_total_inf(Ubc_business, TotalInf),
    r_all_critical_inf(Ubc_business, CritInf).

% r_equals(R1,R2) is true if json object R1 (taken from Yelp) is contained within R2 (Hedgehog) as a name.
r_equals(R1, R2) :-
    r_address(R2, A2),
    yelp_address(R1, A1),
    atom_string(Atom_A2, A2),
    A1 == Atom_A2.

%r_update_all_ifs(Filtered, Rs, L) is true when L is a list of 
r_update_all_ifs([], []).
r_update_all_ifs(Filtered, [L1|L]) :-
    [X|Xs] = Filtered,
    rests(Rs),
    r_update_ifs(X, Rs, L1),
    r_update_all_ifs(Xs, L).

% r_update_ifs(B, R, MR) is true when MR contains the inersection of B and R represented internally
r_update_ifs(Business, [], MyR) :-
    build_restaurant(Business, MyR).
r_update_ifs(Business, Rs, MyR) :-
    [Y|_] = Rs,
    r_equals(Business, Y),
    build_restaurant(Business, Y, MyR).
r_update_ifs(Business, Rs, MyR) :-
    [_|Ys] = Rs,
    r_update_ifs(Business, Ys, MyR).

/*r_update_all_ifs([_10850{
    alias:"loafe-cafe-vancouver", 
    categories:[_11158{alias:"cafes", title:"Cafes"}], 
    coordinates:_11188{latitude:49.2660229, longitude: -123.2491421}, 
    display_phone:"", 
    distance:119.65906091990973, 
    id:"D02tg_m6dxwgz0473aYDfA", 
    image_url:"https://s3-media4.fl.yelpcdn.com/bphoto/hhbG2TLRXxhINw9caFJrYQ/o.jpg", 
    is_closed:false, 
    location:_10996{address1:"6163 University Boulevard", address2:"", address3:"", city:"Vancouver", country:"CA", 
    display_address:["6163 University Blvd", "Vancouver, BC V6T 1Z1", "Canada"], state:"BC", zip_code:"V6T 1Z1"}, name:"Loafe Cafe", phone:"", price:"$", rating:4.0, review_count:36, transactions:[], url:"https://www.yelp.com/biz/loafe-cafe-vancouver?adjust_creative=sg5ZSCMjYVPZP8i4gO9big&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=sg5ZSCMjYVPZP8i4gO9big"}, 
_21564{alias:"rain-or-shine-vancouver", categories:[_21868{alias:"icecream", title:"Ice Cream & Frozen Yogurt"}], coordinates:_21906{latitude:49.2663463, longitude: -123.2467852}, display_phone:"+1 604-620-2004", distance:324.5953463511655, id:"CQAc8CFadjY8fv3mkaEWxw", image_url:"https://s3-media1.fl.yelpcdn.com/bphoto/IL64o7A7ugZ7YCkPrRRwLQ/o.jpg", is_closed:false, location:_21712{address1:"6001 University Boulevard", address2:"", address3:null, city:"Vancouver", country:"CA", display_address:["6001 University Boulevard", "Vancouver, BC V5H 3Z7", "Canada"], state:"BC", zip_code:"V5H 3Z7"}, name:"Rain or Shine", phone:"+16046202004", price:"$$", rating:4.0, review_count:24, transactions:[], url:"https://www.yelp.com/biz/rain-or-shine-vancouver?adjust_creative=sg5ZSCMjYVPZP8i4gO9big&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=sg5ZSCMjYVPZP8i4gO9big"}], L). */