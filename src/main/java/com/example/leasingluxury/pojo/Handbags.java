package com.example.leasingluxury.pojo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.validator.constraints.Length;
import org.hibernate.validator.constraints.Range;

import javax.validation.constraints.DecimalMax;
import javax.validation.constraints.Digits;
import javax.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Handbags {

    // 包的ID
    private String bagID;

    // 包的名字
    @NotNull(message = "请输入包的名字")
    @Length(message = "包的名字不能超过{max}个字符", max = 30)
    private String bagName;

    // 包的生产商
    @NotNull(message = "请输入生产商的名字")
    @Length(message = "生产商的名字不能超过{max}个字符", max = 20)
    private String manufacturer;

    // 包的设计师
    @NotNull(message = "请输入设计师的名字")
    @Length(message = "设计师的名字不能超过{max}个字符", max = 20)
    private String designer;

    // 包的类型
    @NotNull(message = "请输入包的类型")
    @Length(message = "包的类型不能超过{max}个字符", max = 20)
    private String bagType;

    // 包的颜色
    @NotNull(message = "请输入包的颜色")
    @Length(message = "包的颜色不能超过{max}个字符", max = 20)
    private String color;

    // 包的租金
    // TODO: 处理输入的不是数字的问题。输入为字符时，msg为后台报错信息
    @NotNull(message = "请输入包的日租金")
    @Digits(message = "日租金的整数部分不超过{integer}位，小数部分不超过{fraction}位", integer = 2, fraction = 2)
    @Range(message = "日租金范围应在{min}到{max}之间", min=0, max=100)
    private double pricePerDay;

    // 包的状态 0为“在库”；1为“借出”
    private int bagStatus;
}
