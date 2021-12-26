package com.example.leasingluxury.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.validator.constraints.Length;

import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Customers {

    // 客户ID
    private String customerID;

    // 名
    @NotNull(message = "请输入名")
    @Length(message = "firstName不能超过{max}个字符", max=20)
    private String firstName;

    // 姓
    @NotNull(message = "请输入姓")
    @Length(message = "lastName不能超过{max}个字符", max=20)
    private String lastName;

    // 电话号码
    @NotNull(message = "请输入电话号码")
    @Size(message = "电话号码应为{min}位", min = 10, max = 10)
    private String phone;

    // 地址
    @NotNull(message = "请输入地址")
    private String address;

    // 邮箱
    @NotNull(message = "请输入邮箱")
    @Length(message = "邮箱不能超过{max}个字符", max=20)
    private String emailAddr;

    // 信用卡号
    @NotNull(message = "请输入信用卡号")
    @Size(message = "信用卡号应为{min}位", min = 12, max = 12)
    private String creditCardID;

    // 总租期 此处为(dateReturned-dateRented)，而不是实际已租多少天
    private int totalLengthOfRental;

}
