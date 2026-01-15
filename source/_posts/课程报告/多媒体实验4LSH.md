---
title: 多媒体实验4：LSH局部敏感哈希
tags:   
  - 课程
  - 多媒体数据处理
  - 实验报告
  - KNN 问题
  - 局部敏感哈希
categories: 课程报告
date: 2023-06-14 11:47:13
---

## 前言

KNN 问题是指求一个空间内一个点的 K 个最近邻的问题。DB 局部敏感哈希是 KNN 问题的一个快速求取方案，但是它的结果不能保证绝对准确。 <!-- more -->

## 目的

在corel数据集上实现LSH索引并分别进行近邻搜索，查询数据集前1000点的前10个最近邻，并统计搜索算法的性能(召回率，准确率，时间)。

## 局部敏感哈希的思想

常规的哈希思想是通过算法将被哈希后的值作为键去索引原来的值，由于根据值是可以算出键的，所以这就给我们的查找带来了方便。通过哈希，我们可以把一个稀疏矩阵紧密存放，但是又不损失索引的速度。

不过哈希函数也有别的用法，例如密码学哈希函数。这类特别的哈希算法旨在用哈希函数实现加密，因此其哈希值难以推出原值，而且对输入敏感，稍加变动就会彻底改变哈希值。此外，其对抗碰撞的要求也很高，因为碰撞意味着加密的不安全。

而局部敏感哈希则反其道而行之，其非常容易发生碰撞。实际上，这种哈希函数的目的是使邻近的值在经过哈希以后依然邻近，或者说干脆就相等了（这一步可以通过把处理后的值取整实现）。因此，通过局部敏感哈希，我们就相当于对数据集中的数进行了一次分类，这样以后需要搜索 KNN 时，我们就不需要搜索整个数据空间而只对与查询值具有相同哈希值的那些点进行计算即可。

当然，哈希函数不能保证所有被映射到一起的值均是邻近的值，因此 LSH 只能是 KNN 的近似算法，不能保证准确。

> 一个简单的例子是：
> 令哈希函数为 $h((x，y))= x$ ，即 x 轴值。那么 y 轴方向上距离很大的点依然会被错误的认为是邻近点

为了提高准确性，我们可以试着改变哈希算法的一些参数，使得更多的点映射在一起，相当于扩大了“邻近”的范围从而匹配到更多的点。另一方面，我们也可以采用另外一个不同的哈希函数进行运算，看看结果是否会不同。对于多次哈希的结果，我们可以取邻近点的交集，也可以取邻近点的并集，只要参数适当，都可以取得还不错的结果。事实上，由于处理的数据往往维数很大，所以我们都需要采取多个哈希函数。

> 例如对于上面的例子，我们采用$h((x，y))= y$ 作为第二个哈希函数算法，并且认为只有两次哈希结果均邻近才能算邻近值（取交集），那么 y 轴方向上距离很大的点就不会被认为是邻近点。

前人们已经总结出了许多的哈希函数，针对不同的要求，例如求的是点的什么距离，我们可以采取不同的哈希方法。因此我们可以不自己构造哈希函数。

总结一下，LSH 思想就是：通过构造哈希函数将相邻近的点映射到一起，用多次哈希提高精确度，用查找哈希值索引到可能的最邻近点并计算距离得出近似最邻近点。当参数取得合适，我们就可以保证 LSH 找到 KNN 的准确性可以接受。

## 性能评估：准确率、精确率、召回率

准确率、精确率、召回率是三个容易混淆的概念。

假设我们的问题是在所有样本中找出所有为真的样本。那么对于机器给出的结果，就有“机器判断正确/错误”和“机器判断是真/假”的组合共计四种情况，记前者为 True/False，后者为 Positive/Negative，并简记为TFPN。那么机器就将样本分为了 TN、TP、FN、FP 四种类别。于是：

1. 准确率（accuracy）指机器对多少样本的判断是正确的，即 $\frac{TP+TN}{TP+TN+FP+FN}$。准确率只在乎判断得对不对;
2. 精确率/查准率（precision）指预测为真的样本中有多少判断是正确的，也就是 $\frac{TP}{TP+FP}$，精确率要求没有找到错误的真点，不关心有没有漏找;
3. 召回率/查全率（recall）指实际为真的样本中有多少判断是正确的，也就是究竟找（召）回了多少为真的样本，即$\frac{TP}{TP+FN}$，召回率只关心有没有找全真点，不关心有没有错误的点。

在灾害预报中，我们应该关心召回率，因为每一次没有预测到灾害都会给社会带来巨大损失；但是如果是人脸识别，那么就应该关心精确率，因为无法识别人脸用户可以使用其他方式继续，但是如果错误识别则可能给用户带来损失。

也可以用语言的角度进行理解，准确无疑是指我们判断对了没有，精确则是判读对了多少。因此前者关心整体的判断，而后者只关心预测为真的样本中的判断。

## 程序的基本结构

在这里，我采取的是计算欧几里得距离，这样，我们的哈希函数就可以形如

$$H(x) = floor(\frac{(\vec{r}\cdot\vec{p})+b}{H_{size}})$$

其中 $H_{size}$ 是提前指定的值，$\vec{p}$ 是输入点的向量形式，$b$ 和 $\vec{r}$ 是哈希函数中的随机偏移量和随机向量，$b$ 的取值范围在 $(0,H_{size})$ 间。向下取整的 floor 函数负责将邻近的值舍入到一起。

在程序的一开始，我们根据需要的哈希数量和 $H_{size}$ 的值随机生成 $b$ 和 $\vec{r}$。由于矩阵的性质，我们可以直接将前者生成为一维数组，后者为每列一个 $\vec{r}$ 的矩阵。然后对点进行计算。

得出计算结果后，我们使用字典列表按哈希值进行分类保存。这样索引就算建立完毕了。

搜索时，首先计算待查询值的哈希值，然后查询索引获得候选最邻近点。对不同哈希给出的候选集可以使用并集的方法，也可以采取交集的方法。最后对给出的所有候选点计算欧几里得距离，排序后选出最近的前 K 个点即可。选择并集或者交集需要适当的修改参数，不过总的来说，并集的效果好一些（见后面结果）。

在本例中，主要可以修改的参数是 $H_{size}$ 是哈希函数的数量。前者决定了对计算结果的区分度， $H_{size}$ 越大，被哈希到一起的邻近点就越多,速度就越慢，但是精确度相应提升。后者则可以从不同方向来判断邻近点，哈希函数越多，邻近点就越多，但是速度也同样会变慢。

为了判断精确度和用时，我们还需要构造一份正确答案。可以采取暴力计算的方式进行。将结果作为 JSON 文件存储于磁盘内，就可以加速在判断 LSH 准确性时的速度。

## 源代码

LSH:

```python

import numpy as np
import json
import time

# region functions

def get_hash_para(BUKET_SIZE):
    offsets = np.random.uniform(0, BUKET_SIZE, [1, BUCKET_NUM])
    vectors = np.random.random([32, BUCKET_NUM])
    return offsets, vectors


def calc_LSH_indexes(data, bucket_num):
    """" 
    进行哈希计算并分配到哈希“桶”中\\
    哈希公式 H = （（dot（v·r）+b)）/BUCKET_SIZE）\\ 
        其中r是向量，b是一个数
    """
    buckets = [{}for _ in range(bucket_num)]
    # 结果是68040*15，每个向量在每个桶内映射为一个哈希值
    mapped_indexes = np.floor(
        (np.dot(data, hash_vectors)+hash_offsets)/BUCKET_SIZE)

    # 由（数据向量值的）索引对应的一串桶中的哈希值，转变为桶中的哈希值对应的索引
    # 方便由哈希值找索引
    for index, hash_keys in enumerate(mapped_indexes):
        for j, hash_key in enumerate(hash_keys):
            buckets[j].setdefault(hash_key, []).append(index)

    return buckets


def get_distance(a, b):
    """"获得欧几里得距离"""
    return np.sqrt(np.sum((a-b)**2))


def search(query, k):
    """"搜索点query的K最邻近"""

    # 对该点哈希
    # 1*【桶数】
    query_hash_set = np.floor(
        (np.dot(query, hash_vectors)+hash_offsets)/BUCKET_SIZE)
    query_hash_set = query_hash_set[0]

    # get哈希值相同的点：候选点
    for i, query_hash in enumerate(query_hash_set):
        if i == 0:
            candidate_set = set(buckets[i][query_hash])
        else:
            candidate_set = candidate_set.union(
                buckets[i][query_hash])
    candidate_set = list(candidate_set)

    # 计算排序候选点距离
    distance = []
    for i in candidate_set:
        distance.append(get_distance(query, data[i]))

    indexes_set = np.argsort(distance)[1:k+1]
    res = [candidate_set[i] for i in indexes_set]
    return res


def search_with_intersection(query, k):
    """"搜索点query的K最邻近,交集"""

    # 对该点哈希
    # 1*【桶数】
    query_hash_set = np.floor(
        (np.dot(query, hash_vectors)+hash_offsets)/BUCKET_SIZE)
    query_hash_set = query_hash_set[0]

    # get哈希值相同的点：候选点
    for i, query_hash in enumerate(query_hash_set):
        if i == 0:
            candidate_set = set(buckets[i][query_hash])
        else:
            candidate_set = candidate_set.intersection(
                buckets[i][query_hash])
    candidate_set = list(candidate_set)

    # 计算排序候选点距离
    distance = []
    for i in candidate_set:
        distance.append(get_distance(query, data[i]))

    indexes_set = np.argsort(distance)[1:k+1]
    res = [candidate_set[i] for i in indexes_set]
    return res


def check_accuracy(chk_res, crrt_res):
    # 如果check-res中的元素在correct-res则append一个ture
    correct_num = sum([i in crrt_res for i in chk_res])
    TP = correct_num
    FP = K - correct_num
    FN = K - correct_num
    TN = (68040 - K) - FN

    accuracy = (TP+TN)/(TP+TN+FP+FN)

    precision = (TP)/(TP+FP)
    recall = (TP)/(TP+FN)
    return accuracy, precision, recall


# endregion


if __name__ == '__main__':

    # 变量
    COREL_PATH = './multi/4.corel'
    CRRCT_RES_PATH = './multi/4.10NN.json'
    BUCKET_NUM = 5    # 提高哈希量：增加准确性降低速度，时间的增加是几乎线性的
    BUCKET_SIZE = 1.5  # （降低数值）提高区分度：降低准确性增加速度
    K = 10
    buckets = []

    mean_precision = 0
    mean_recall = 0

    total_hash_time = -1
    total_bf_time = -1  
    total_pre_time = -1  

    # 文件读取
    data = np.loadtxt(COREL_PATH, usecols=range(1, 33))
    with open(CRRCT_RES_PATH, 'r') as f:
        correct_res_set = json.load(f)

    # 预处理
    pre_start_time = time.time()

    hash_offsets, hash_vectors = get_hash_para(BUCKET_SIZE)
    buckets = calc_LSH_indexes(data,  BUCKET_NUM)

    total_pre_time = time.time()-pre_start_time

    # 查询
    hash_start_time = time.time()

    for query in range(0, 1000):
        # hash
        print('query index:', query)

        res = search_with_intersection(data[query], K)

        hash_end_time = time.time()

        # bf
        bf_res = correct_res_set[str(query)]

        # 评估
        _, precision, recall = check_accuracy(
            chk_res=res, crrt_res=bf_res)
        mean_precision += precision
        mean_recall += recall

    total_hash_time += time.time()-hash_start_time + 1

    # 结果
    mean_precision /= 1000
    mean_recall /= 1000
    print('hash used time:', total_hash_time,
          'hash preprocess time ', total_pre_time,
          ' bf used time:', total_bf_time)
    print('precision:', mean_precision, 'recall:', mean_recall)

```

暴力：

```python
import numpy as np
from sklearn.cluster import KMeans
from scipy.cluster.vq import vq
import json
import time
from sklearn.metrics.pairwise import cosine_similarity


# region functions


def get_distance(a, b):
    """"获得欧几里得距离"""
    return np.sqrt(np.sum((a-b)**2))


def check_accuracy(check_res, correct_res):
    accurate_num = sum([i in correct_res for i in check_res])
    # false_num = K - accurate_num
    TP = accurate_num
    FP = K - accurate_num
    FN = K - accurate_num
    TN = (68040 - K) - FN

    accuracy = (TP+TN)/(TP+TN+FP+FN)
    precision = (TP)/(TP+FP)
    recall = (TP)/(TP+FN)
    return accuracy, precision, recall


# endregion


if __name__ == '__main__':

    # variables
    COREL_PATH = './multi/4.corel'
    CRRCT_PATH = './multi/4.10NN.json'
    K = 10


    # 预处理
    hash_pre_time = time.time()

    data = np.loadtxt(COREL_PATH, usecols=range(1, 33))

    hash_pre_used_time = time.time()-hash_pre_time
    # 查询
    mean_accuracy = 0
    mean_precision = 0
    mean_recall = 0
    total_hash_time = 0
    total_bf_time = 0

    bf_res_set = {}
    for query_index in range(0, 1000):
        bf_res = [get_distance(data[i], data[query_index])
                  for i in range(data.shape[0])]
        bf_res = np.argsort(bf_res)[1: 11].tolist()
        bf_res_set[query_index] = bf_res
        print(query_index)
    with open(CRRCT_PATH, 'w') as f:
        f.write('{\n')
        for i, (key, value) in enumerate(bf_res_set.items()):
            f.write(f'    "{key}": {json.dumps(value)}')
            if i < len(bf_res_set) - 1:
                f.write(',')
            f.write('\n')
        f.write('}\n')
```

## 准确率与参数参考

需要说明是，准确性和时间受随机与性能的影响很大，因此以下结果仅作参考。

候选点交集：

>交集
> num：5 size = 1.5 search_time : 350   preicision: 0.94
> num：5 size = 1.1 search_time : 168   preicision: 0.84
> num：5 size = 1.0 search_time : 247   preicision: 0.91
> num：5 size = 1.0 search_time : 119   preicision: 0.84 //这一步可以看到随机对结果和性能的影响
> num：5 size = 0.5 search_time : 146   preicision: 0.77
> num：5 size = 0.5 search_time : 100   preicision: 0.77
> num：5 size = 0.2 search_time : 11    preicision: 0.53
> num：5 size = 0.1 search_time : 3.39  preicision: 0.25

取并集：

> 并集
> 哈希一次
> num：1 size = 0.02   search_time : 18     preicision:0.25
> num：1 size = 0.05   search_time : 46     preicision:0.50
> num：1 size = 0.10   search_time : 90     preicision:0.74
> num：1 size = 0.20   search_time : 169    preicision:0.87
> 哈希三次
>num： 3 size = 0.02   search_time : 58     preicision:0.60
>num： 3 size = 0.05   search_time : 153    preicision:0.96
>num： 3 size = 0.10   search_time : 230    preicision:0.97
> 哈希五次：
>num： 5 size = 0.01   search_time : 47     preicision:0.49
>num： 5 size = 0.02   search_time : 86     preicision:0.72
>num： 5 size = 0.05   search_time : 189    preicision:0.96
>num： 5 size = 0.10   search_time : 290    preicision:0.997

## 参考

- [xducs/多媒体数据处理/LSH.ipynb at main · silence-tang/xducs · GitHub](https://github.com/silence-tang/xducs/blob/main/%E5%A4%9A%E5%AA%92%E4%BD%93%E6%95%B0%E6%8D%AE%E5%A4%84%E7%90%86/LSH.ipynb)
- [一文看懂机器学习指标：准确率、精准率、召回率、F1、ROC曲线、AUC曲线 - 知乎](https://zhuanlan.zhihu.com/p/93107394)
