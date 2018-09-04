#!/bin/bash

kvinit() {
    if [ ! -e .kv ]; then
        mkdir -p .kv
    fi;
}

kvset() {
    kvinit;
    key="$1";
    hash=$(echo -n $key | sha256sum | tr -d ' -')
    folder=$(echo -n $hash | cut -c 1-4);

    if [ ! -e ".kv/$folder" ]; then
        mkdir -p ".kv/$folder";
    fi;    

    echo "$key" > ".kv/$folder/$hash.key";
    cat /dev/stdin | lz4 > ".kv/$folder/$hash.lz4";
}

kvadd() {
    kvset $1;
}

kvdel() {
    if [ ! -e ".kv" ]; then
        return 0;
    fi;

    key="$1";
    hash=$(echo -n $key | sha256sum | tr -d ' -')
    folder=$(echo -n $hash | cut -c 1-4);

    rm -f ".kv/$folder/$hash"*;
}

kvclear() {
    rm -rf .kv
}

kvget() {
    if [ ! -e ".kv" ]; then
        return 1;
    fi;

    kvinit;
    key="$1";
    hash=$(echo -n $key | sha256sum | tr -d ' -')
    folder=$(echo -n $hash | cut -c 1-4);

    if [ -e ".kv/$folder/$hash.lz4" ]; then
        lz4cat ".kv/$folder/$hash.lz4";
        return 0;
    fi;
    
    return 1;
}

kvcontains() {
    if [ ! -e ".kv" ]; then
        return 1;
    fi;

    key="$1";
    hash=$(echo -n $key | sha256sum | tr -d ' -')
    folder=$(echo -n $hash | cut -c 1-4);

    if [ -e ".kv/$folder/$hash.lz4" ]; then
        return 0;
    fi;
    return 1;
}

kvlist() {
    if [ ! -e ".kv" ]; then
        return 1;
    fi;
    find .kv -name "*.key" | xargs cat
}

kvcount() {
    if [ ! -e ".kv" ]; then
        echo 0;
        return;
    fi;
    find .kv -name "*.key" | wc -l
}
