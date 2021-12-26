package com.example.leasingluxury.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.Future;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import javax.validation.constraints.NotNull;
import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Rentals {

    // 交易ID
    private String rentalID;

    // 客户ID
    @NotBlank(message = "请选择一个客户")
    private String customerID;

    // 包ID
    @NotBlank(message = "请选择一个包包")
    private String bagID;

    // 租用时间
    @NotNull(message = "请输入租赁日期")
    private Date dateRented;

    // 可以考虑让客户选择租多少天，后台自动计算归还日期

    // 归还时间
    @NotNull(message = "请输入归还日期")
    @Future(message = "归还日期请输入未来的日期")
    private Date dateReturned;

    // 是否购买保险 0为不购买；1为购买
    @NotNull(message = "请选择是否购买保险")
    private int insurance;

    // 归还状态 0为未归还；1为已归还
    private int returnStatus;

}
