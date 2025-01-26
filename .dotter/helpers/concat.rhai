fn join_with_separator(params) {
    let separator = params[0];
    let result = "";

    for i in 1..params.len() {
        result += params[i];
        if i < params.len() - 1 {
            result += separator;
        }
    }

    return result;
}

return join_with_separator(params);
