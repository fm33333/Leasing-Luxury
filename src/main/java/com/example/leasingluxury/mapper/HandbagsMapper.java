package com.example.leasingluxury.mapper;

import com.example.leasingluxury.pojo.Handbags;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;

// Mapper注解表示这是一个mybatis的mapper类：Dao
@Mapper
@Repository
public interface HandbagsMapper {

    /**
     * 获取所有的包
     * @return 所有包信息的列表
     */
    List<Handbags> queryHandbagsList();

    /**
     * 根据包名获取包的信息
     * @param bagName
     * @return 包的信息
     */
    Handbags getHandbagByName(String bagName);

    /**
     * 添加新的包
     * @return 添加数量（成功为1）
     */
    int add_handbags(String bagName, String manufacturer, String designer,
                      String bagType, String color, double pricePerDay);

    /**
     * 获取指定设计师的包
     * @param designer
     * @return 一系列包的信息
     */
    List<Handbags> bag_by_manufacturer(String designer);

    /**
     * 模糊查询，搜索包包信息
     * @param searchContent
     * @return 一系列包的信息
     */
//    List<Handbags> searchAllHandbags(String searchContent);

    /**
     * 根据searchType查询包
     * @param searchType
     * @param searchContent
     * @return
     */
    List<Handbags> searchHandbags(String searchType, String searchContent);

    /**
     * 根据bagID获取包包信息
     * @param bagID
     * @return 包的信息
     */
    Handbags getHandbagsByID(String bagID);

    /**
     * 更新包的信息
     * @param handbag
     */
    void updateHandbags(String bagID, String bagName, String manufacturer, String designer,
                        String bagType, String color, double pricePerDay);

    /**
     * 根据bagID删除包包
     * @param bagID
     */
    void deleteHandbagsByID(String bagID);

    /**
     * 根据bagID获取包包名字
     * @param bagID
     * @return 包包名字
     */
    String getHandbagNameByID(String bagID);

    /**
     * 获取所有的设计师名字
     * @return 设计师名字列表
     */
    List<String> getAllDesigners();

    /**
     * 根据设计师查找包包
     * @param designer
     * @return 包包列表
     */
    List<Handbags> bag_by_designer(String designer);

}
