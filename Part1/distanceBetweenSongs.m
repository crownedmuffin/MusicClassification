function d = distanceBetweenSongs(song1_signal,song1_sampleRate,song2_signal,song2_sampleRate)
    %mfcc coefficiencts of song 1 and 2 respectively
    
    %mfcc(wav, fs, fftSize, window)
    %[song1_signal, ] = audioread(song1_path)
    
    %frame size shall be 512 as described in project
    frameSize_N = 512;
    window = hann(frameSize_N);
    
    %Compute mfcc coefficients for each song
    mfcc1 = mfcc(song1_signal,song1_sampleRate,frameSize_N,window);
    mfcc1(:,length(mfcc1)) = '';
    
    mfcc2 = mfcc(song2_signal,song2_sampleRate,frameSize_N,window);
    mfcc2(:,length(mfcc2)) = '';
    
    %Redefinition of filter bank
    t = zeros(1,36); 
    t(1) =1;t(7:8)=5;t(15:18)= 9;
    t(2) = 2; t( 9:10) = 6; t(19:23) = 10;
    t(3:4) = 3; t(11:12) = 7; t(24:29) = 11;
    t(5:6) = 4; t(13:14) = 8; t(30:36) = 12;
    

    %{
    -----------------------Pass mfcc1 through merged mel bank filters-----------------------
    %}
    mel2 = zeros(12,size(mfcc1,2));
    for i=1:12,
        mel2(i,:) = sum(mfcc1(t==i,:),1);
    end
    mfcc1 = mel2;
    
    
    %{
    -----------------------Pass mfcc2 through merged mel bank filters-----------------------
    %} 
    mel2 = zeros(12,size(mfcc2,2));
    for i=1:12,
        mel2(i,:) = sum(mfcc2(t==i,:),1);
    end
    mfcc2 = mel2;


    %{
    -----------------------4.7 COMPUTING DISTANCE BETWEEN FEATURES-----------------------
                                Answers questions 6 and 7
    %} 

    %{
        In general, we are collapsing the information gathered about the
        songs, in previous section, into an average note, and a covariance
        matrix (telling us how much each element of the song is correlated to itself. - not a
        very good explanation of it...)

        Mean note of song used to categorize it
        mu = mean(mfcc,2);

        Covariance of song used to categorize it
        Cov = cov(mfcc);

        The Kullback-Leibler divergence is given in equation (23) on page
        20

        Computing this value will allow us to compute the distance between
        two songs.

    %}

    %Computing the distance d between the two tracks s1 and s2 

    %Going to include implementation of Professor Meyer's code here:

    mu1 = mean(mfcc1,2);
    mu2 = mean(mfcc2,2);

    co1 = cov(mfcc1');
    co2 = cov(mfcc2');
    
    try
       tic
            iCo1 = pinv(co1);
            iCo2 = pinv(co2);
        toc
    catch
        warning('Pseudo-Inverse not working.')
    end

    %{
        try
            tic
                iCo1 = inv(co1);
                iCo2 = inv(co2);
            toc
        catch
            warning('Inverse not working.')
        end
    %}
    
    %{
        Moore-penrose pseudoinverse for a singluar matrix

        ico1 = pinv(co1);
        ico2 = pinv(co2);                    
    %}

    tic
        KL = trace(co1*iCo2) + trace(co2*iCo1) + (mu1-mu2)'*(iCo1+iCo2)*(mu1-mu2);
    toc
    gam = 1e2;
    d = 1 - exp(-gam/(KL + eps));
end 