pragma circom 2.0.0;
// include "../../node_modules/circomlib/circuits";

template Main() {
    signal input totalScore;
    signal input totalEvaluater;
    signal input encryptionKeyN;
    signal input decriptionKeyLambda;
    signal input decriptionKeyMu;
    signal averageScore;
    signal output rating;
    signal rem;
    signal plainTotScore;
    signal plainTotEvaluater;

    // 平均スコアの計算
    // var invTotalEvaluater = totalEvaluater != 0 ? 1 / totalEvaluater : 0;
    // averageScore <== totalScore * invTotalEvaluater;
    plainTotScore <-- decrypt(totalScore, encryptionKeyN, decriptionKeyLambda, decriptionKeyMu);
    plainTotEvaluater <-- decrypt(totalEvaluater, encryptionKeyN, decriptionKeyLambda, decriptionKeyMu);
    log("plainTotScore is", plainTotScore);
    log("plainTotEvaluater is", plainTotEvaluater);

    averageScore <-- plainTotScore \ plainTotEvaluater;
    log("averageScore is", averageScore);
    rem <-- plainTotScore % plainTotEvaluater;
    averageScore * plainTotEvaluater + rem === plainTotScore;

    // 平均スコアの計算
    // signal averageScore;
    // component inv = FpInverse();
    // inv.in <== totalEvaluater;
    // averageScore <== totalScore * inv.out;


    // 5段階評価の計算
    component computeRating = ComputeRating();
    computeRating.averageScore <== averageScore;
    computeRating.rating ==> rating;
}

function decrypt(chipher, ekN, dkLambda, dkMu) {
    var ekNN = ekN * ekN;
    log("ekNN is", ekNN);
    var plainNumer = (powMod(chipher, dkLambda, ekNN) - 1) \ ekN;
    log("plainNumer is", plainNumer);
    log("dkMu is", dkMu);
    var plain = plainNumer * dkMu % ekN;
    log("ekN is", ekN);
    return plain;
}

function powMod(x, e, m) {
    var result = 1;
    while (e > 0) {
        if (e % 2 == 1) {
            result = (result * x) % m;
        }
        x = (x * x) % m;
        e = e >> 1;
    }
    return result;
}

template ComputeRating() {
    signal input averageScore;
    signal output rating;

    // 0 ~ 20 -> 1, 21 ~ 40 -> 2, 41 ~ 60 -> 3, 61 ~ 80 -> 4, 81 ~ 100 -> 5
    signal isLevel1;
    signal isLevel2;
    signal isLevel3;
    signal isLevel4;
    signal isLevel5;

    isLevel1 <-- (0 <= averageScore) * (averageScore <= 20);
    isLevel2 <-- (21 <= averageScore) * (averageScore <= 40);
    isLevel3 <-- (41 <= averageScore) * (averageScore <= 60);
    isLevel4 <-- (61 <= averageScore) * (averageScore <= 80);
    isLevel5 <-- (81 <= averageScore) * (averageScore <= 100);

    // signal isWithinLowerBound;
    // signal isWithinUpperBound;

    // isWithinLowerBound <== 0 <= averageScore;
    // isWithinUpperBound <== averageScore <= 20;

    // isLevel1 <== isWithinLowerBound * isWithinUpperBound;

    rating <== 1 * isLevel1 + 2 * isLevel2 + 3 * isLevel3 + 4 * isLevel4 + 5 * isLevel5;
    // rating <== 1 * isLevel1;
}

component main {public [totalScore, totalEvaluater, encryptionKeyN]} = Main();
