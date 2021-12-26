package com.example.leasingluxury.mapper;

import com.example.leasingluxury.pojo.AmountInfo;
import com.example.leasingluxury.pojo.Customers;
import org.apache.ibatis.annotations.Mapper;
import org.springframework.stereotype.Repository;

import java.util.List;

@Mapper
@Repository
public interface CustomersMapper {

    /**
     * 获取所有的客户
     * @return 客户列表
     */
    List<Customers> queryCustomersList();

    /**
     * 模糊查询客户信息
     * @param searchType
     * @param searchContent
     * @return 客户列表
     */
    List<Customers> searchCustomers(String searchType, String searchContent);

    /**
     * 添加客户
     * @param firstName
     * @param lastName
     * @param phone
     * @param address
     * @param emailAddr
     * @param creditCardID
     */
    void add_customers(String firstName, String lastName, String phone,
                       String address, String emailAddr, String creditCardID);

    /**
     * 通过customerID获得客户信息
     * @param customerID
     * @return 客户信息
     */
    Customers getCustomerByID(String customerID);

    /**
     * 更新客户信息
     * @param customerID
     * @param firstName
     * @param lastName
     * @param phone
     * @param address
     * @param emailAddr
     * @param creditCardID
     */
    void updateCustomers(String customerID, String firstName, String lastName, String phone,
                         String address, String emailAddr, String creditCardID);

    /**
     * 根据customerID删除客户
     * @param customerID
     */
    void deleteCustomersByID(String customerID);

    /**
     * 根据customerID获得客户的名字
     * @param customerID
     * @return 客户名字
     */
    String getCustomerFirstNameByID(String customerID);

    /**
     * 根据customerID获得客户的姓氏
     * @param customerID
     * @return 客户姓氏
     */
    String getCustomerLastNameByID(String customerID);

    /**
     * 获取按租赁总天数降序排序的客户列表
     * @return 客户列表
     */
    List<Customers> best_customers();

    /**
     * 获取客户的消费信息列表
     * @param customerID
     * @return 消费信息列表
     */
    List<AmountInfo> report_customer_amount(String customerID);

}
