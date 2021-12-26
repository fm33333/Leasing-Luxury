package com.example.leasingluxury.mapper;

import com.example.leasingluxury.pojo.Rentals;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;
import java.util.Map;

@Mapper
@Repository
public interface RentalsMapper {

    /**
     * 获取所有的租赁信息
     * @return 租赁信息列表
     */
    List<Rentals> queryRentalsList();

    /**
     * 模糊查询租赁信息
     * @param searchType
     * @param searchContent
     * @return 租赁信息列表
     */
    List<Rentals> searchRentals(String searchType, String searchContent);

    /**
     * 添加租赁记录
     * @param customerID
     * @param bagID
     * @param dateRented
     * @param dateReturned
     * @param insurance
     */
    void add_rentals(String customerID, String bagID,
                     Date dateRented, Date dateReturned,
                     int insurance);

    /**
     * 归还包包并打印该次租赁总天数
     * @param rentalID
     * @return 租赁总天数
     */
    Integer report_info_afterReturned(String rentalID);

    /**
     * 归还包包并打印该次租赁总金额
     * @param rentalID
     * @return 租赁总金额
     */
    Double report_info2_afterReturned(String rentalID);

    /**
     * 根据rentalID获取租赁消息
     * @param rentalID
     * @return 租赁消息
     */
    Rentals getRentalByID(String rentalID);

    /**
     * 删除租赁记录
     * @param rentalID
     */
    void deleteRentals(String rentalID);

}
