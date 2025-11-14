function save_scores(results, model_name)
    scores_all = {results.scores}
    labels_all = {results.labels}

    disp(model_name)

    for i = 1 : size(scores_all,2)
        S = scores_all{i};
        L = labels_all{i};

        keep = L == 1;

        S = S(keep,:);
        disp (S)
    end
end
