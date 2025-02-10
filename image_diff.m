function image_diff = image_diff(image1, image2)
    found_problem = 0;
    for i = 1:size(image1, 1)
        for j = 1:size(image1, 2)
            if (round(image1(i, j) - image2(i, j), 2, 'significant') > 0.02)
                found_problem = 1;
                display("wrong " + i + " " + j)
                display(round(image1(i, j) - image2(i, j), 2, 'significant'))
                display(image1(i, j))
                display(image2(i, j))
            end
        end
    end
    display("found_problem: " + found_problem)
    image_diff = found_problem;
end

% 0 if images are the same
% 1 if images are different