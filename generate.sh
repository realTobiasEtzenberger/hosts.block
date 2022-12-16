wget -i white.txt -O whitelist.txt -q
wget -i black.txt -O blacklist.txt -q

cat personal-white.txt >> whitelist.txt

clean_list() {
    echo "Started cleaning $1"

    # Remove 0.0.0.0
    echo "  Remove 0.0.0.0"
    sed 's/0.0.0.0 //' -i $1

    # Remove 127.0.0.1
    echo "  Remove 127.0.0.1"
    sed 's/127.0.0.1 //' -i $1

    # Remove ::
    echo "  Remove ::"
    sed 's/:: //' -i $1

    # Remove Headers & Comments
    echo "  Remove Headers & Comments"
    sed '/#/d' -i $1

    # Remove custom host records
    echo "  Remove custom host records"
    sed '/localhost$/d;/localdomain$/d;/local$/d;/broadcasthost$/d;/ip6-localhost$/d;/ip6-loopback$/d;/ip6-localnet$/d;/ip6-mcastprefix$/d;/ip6-allnodes$/d;/ip6-allrouters$/d;/ip6-allhosts$/d' -i $1

    # Remove Blog Domains and Unwanted Craps
    echo "  Remove Blog Domains and Unwanted Craps"
    sed '/.blogspot./d;/.wixsite./d;/.wordpress./d;/\//d;/:/d;/(/d;/|/d;/\[/d;/\]/d' -i $1

    # Remove Blank/Empty Lines
    echo "  Remove Blank/Empty Lines"
    sed '/^$/d' -i $1

    # Removes Whitespace
    echo "  Removes Whitespace"
    cat $1 | tr -d '\r' > cache.txt

    # Sort, Remove Duplicate and Write
    echo "  Sort, Remove Duplicate and Write"
    sed -i 's/ *$//' cache.txt && sort cache.txt |uniq |tee > $1

    # Clear Cache
    echo "  Clear Cache"
    rm -f cache.txt

    echo "Finished cleaning $1"
}


clean_list whitelist.txt
clean_list blacklist.txt

# Remove Whitelisted Domains
echo "Remove Whitelisted Domains"
comm -23 blacklist.txt whitelist.txt > cache.txt

# Remove Blank/Empty Lines
echo "Remove Blank/Empty Lines"
sed '/^$/d' -i cache.txt

# Adding Info
echo "Updated at $(date)" > info.txt
echo "\nWhitelists:\n" >> info.txt
cat white.txt >> info.txt
echo "\nBlacklist:\n" >> info.txt
cat black.txt >> info.txt
echo "\n\n\n" >> info.txt
awk '$0="# "$0' info.txt > hosts.txt

# Build hosts.txt
echo "Build hosts.txt"
awk '$0="0.0.0.0 "$0' cache.txt >> hosts.txt

# Clear Files
echo "Clear Files"
rm -f cache.txt whitelist.txt blacklist.txt

echo "Domains blocked: $(wc -l hosts.txt)"

echo "Finsihed Script ;)"