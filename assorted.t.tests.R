t.test(subset(trainData_mbb, trainData_mbb$block %in% c(65:68) & trainData_mbb$group %in% c(1))$ide.bc, subset(trainData_mbb, trainData_mbb$block %in% c(65:68) & trainData_mbb$group %in% c(2))$ide.bc, paired = FALSE)


train.gr1.ide.pe = subset(trainData_mbb, trainData_mbb$block %in% c(65:68) & trainData_mbb$group %in% c(1))$ide.bc
train.gr2.ide.pe = subset(trainData_mbb, trainData_mbb$block %in% c(65:68) & trainData_mbb$group %in% c(2))$ide.bc
summary(train.gr1.ide.pe)
summary(train.gr2.ide.pe)
