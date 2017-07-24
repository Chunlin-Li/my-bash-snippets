BEGIN {

#   "curl -XPOST 10.14.1.21:5030 -d '[INFO] test awk send message'" |get line;
    start_time = systime() - 1;

    count_ssp_to = 0;
    ssp_req_to_notified = 0;

    count_vcv_parse_error = 0;
    vcv_parse_error_notified = 0;

    count_resp_header_e = 0;
    resp_header_e_notified = 0;

    count_protobuf_endec_e = 0;
    protobuf_endec_e_notified = 0;
}


{
    if ($0 ~ /_ssp_req_timeout/) {
        if (++count_ssp_to > 100000) {
            if (ssp_req_to_notified == 0) {
                "date -u +%Y-%m-%dT%TZ" |getline time
                system("curl -s -XPOST 10.14.1.21:5030 -d '"$1" console warning: too many ssp req timeout'") time
                ssp_req_to_notified = 1;
            }
        }
    } else if ($0 ~ /(view|click|verify) parse error/) {
        if (++count_vcv_parse_error > 1000) {
            if (vcv_parse_error_notified == 0) {
                "date -u +%Y-%m-%dT%TZ" | getline time
                system("curl -s -XPOST 10.14.1.21:5030 -d '"$1" console warning: too many view/click/verify url parse error'") time
                vcv_parse_error_notified = 1;
            }
        }

    } else if ($0 ~ /response header error/) {
        if (++count_resp_header_e > 1000) {
            if (resp_header_e_notified == 0) {
                "date -u +%Y-%m-%dT%TZ" | getline time
                system("curl -s -XPOST 10.14.1.21:5030 -d '"$1" console warning: too many resp header error'") time
                resp_header_e_notified = 1;
            }
        }

    } else if ($0 ~ /(decode|encode) (request|response) error/) {
        if (++count_protobuf_endec_e > 1000) {
            if (protobuf_endec_e_notified == 0) {
                "date -u +%Y-%m-%dT%TZ" |getline time
                system("curl -s -XPOST 10.14.1.21:5030 -d '"$1" console warning: too many protobuf endec error'") time
                protobuf_endec_e_notified = 1;
            }
        }
    } else if ($4 == "ERROR") {
        system("curl -s -XPOST 10.14.1.21:5030 -d '"$0"'")
#       print "!!!!!!!!  ERROR ", $0
    }
}
